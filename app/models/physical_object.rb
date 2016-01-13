class PhysicalObject < ActiveRecord::Base
  XML_INCLUDE = [:group_total, :carrier_stream_index, :current_workflow_status]
  XML_EXCLUDE = [:container_id, :box_id, :bin_id, :picklist_id, :spreadsheet_id, :unit_id, :workflow_index, :group_key_id, :workflow_status, :format_duration]
  include XMLExportModule
  include WorkflowStatusModule
  extend WorkflowStatusQueryModule
  include ConditionStatusModule
  include ActiveModel::Validations
  include TechnicalMetadatumModule
  extend TechnicalMetadatumClassModule

  after_initialize :default_values, if: :new_record?
  after_initialize :assign_default_workflow_status, if: :new_record?
  before_validation :ensure_tm
  before_validation :ensure_group_key
  before_save :assign_inferred_workflow_status
  after_save :resolve_group_position
  after_save :set_container_format
  after_update :destroy_empty_group
  after_destroy :destroy_empty_group

  belongs_to :box
  belongs_to :bin
  belongs_to :group_key
  belongs_to :picklist
  belongs_to :container
  belongs_to :spreadsheet
  belongs_to :unit
  
  has_one :technical_metadatum, :dependent => :destroy, validate: true
  has_one :digital_provenance, :dependent => :destroy, validate: true
  has_many :workflow_statuses, :dependent => :destroy
  has_many :condition_statuses, :dependent => :destroy
  has_many :notes, :dependent => :destroy
  has_many :digital_statuses, :dependent => :destroy

  accepts_nested_attributes_for :condition_statuses, allow_destroy: true
  accepts_nested_attributes_for :notes, allow_destroy: true
  # below line supports kludge workaround for bug POD-648
  accepts_nested_attributes_for :workflow_statuses, allow_destroy: false

  # default per_page value can be overriden in a request
  self.per_page = 50

  # the number of minutes before a staging request can no longer be undone
  STAGING_UNDO = 0
  # list of workflow statuses where ephemera (if persent) should be returned
  EPHEMERA_RETURNED_STATUSES = ["Unpacked", "Returned to Unit"]

  scope :packing_sort, lambda { order(:call_number, :group_key_id, :group_position, :id) }
  scope :unpacked, lambda { where(bin_id: nil, box_id: nil) }
  scope :unpacked_or_id, lambda { |object_id| where("(bin_id is null and box_id is null) or id = ?", object_id) }
  scope :packed, lambda { where("physical_objects.bin_id > 0 OR physical_objects.box_id > 0") }
  scope :blocked, lambda { joins(:condition_statuses).where(condition_statuses: {active: true, condition_status_template_id: ConditionStatusTemplate.blocking_ids}).includes(:condition_statuses) }

  # this hash holds the human reable attribute name for this class
  HUMANIZED_COLUMNS = {
      :mdpi_barcode => "MDPI barcode",
      :iucat_barcode => "IUCAT barcode",
      :oclc_number => "OCLC number"
  }
  GENERATION_VALUES = hashify ["", "Original", "Copy", "Unknown"]
  SIMPLE_FIELDS = [ 'title', 'title_control_number', 'home_location',
    'call_number', 'iucat_barcode', 'format', 'collection_identifier',
    'mdpi_barcode', 'format_duration', 'has_ephemera', 'author', 'catalog_key',
    'collection_name', 'generation', 'oclc_number', 'other_copies', 'year', 'group_position', 'ephemera_returned' ]
  MULTIVALUED_FIELDSETS = {}

  def valid_formats
    TechnicalMetadatumModule.tm_formats_array
  end
  def self.valid_formats
    TechnicalMetadatumModule.tm_formats_array
  end
  def self.formats
    TechnicalMetadatumModule.tm_formats_hash
  end
  validates :format, presence: true, inclusion: { in: lambda { |po| po.valid_formats }, message: "value \"%{value}\" is not in list of valid values: #{PhysicalObject.valid_formats}}" }
  validates :generation, inclusion: { in: GENERATION_VALUES.keys, message: "value \"%{value}\" is not in list of valid values: #{GENERATION_VALUES.keys}" }
  validates :group_position, presence: true
  validates :mdpi_barcode, mdpi_barcode: true
  validates :unit, presence: true
  validates :group_key, presence: true
  validates :technical_metadatum, presence: true
  validates :digital_provenance, presence: true
  validates :workflow_status, presence: true
  validates_with PhysicalObjectValidator
  validate :validate_single_container_assignment, if: [:bin_id, :box_id]
  validate :validate_bin_container, if: :bin_id
  validate :validate_box_container, if: :box_id
  validate :validate_ephemera_values, if: :ephemera_returned

  accepts_nested_attributes_for :technical_metadatum
  scope :search_by_catalog, lambda {|query| where(["call_number = ?", query, query])}
  scope :search_by_barcode, lambda {|barcode| where(["mdpi_barcode = ? OR iucat_barcode = ?", barcode, barcode])}
  scope :search_id, lambda {|i| 
    where(['mdpi_barcode = ? OR iucat_barcode = ? OR call_number like ?', i, i, i, i])
  }
  scope :search_by_barcode_title_call_number, lambda { |query|
    query = "%#{query}%"
    where("mdpi_barcode like ? or call_number like ? or title like ?", query, query, query)
  }
  scope :advanced_search, lambda {|po| 
    po.physical_object_query(false)
  }

  # no longer used
  # scope :unstaged_by_date, lambda { |date|
  #   PhysicalObject.joins(:digital_statuses).joins("LEFT JOIN digital_statuses as ds2
  #     ON digital_statuses.physical_object_id = ds2.physical_object_id
  #     AND digital_statuses.state = ds2.state
  #     AND digital_statuses.id < ds2.id").where("ds2.id IS NULL").where(staging_requested: false, digital_statuses: { state: DigitalStatus::DIGITAL_STATUS_START}).where(datesql(date))
  #
  # }
  # No longer used
  # scope :staging_requested, lambda { where(staging_requested: true, staged: false) }
  # scope :staged, lambda { where(staged: true) }

  # This scope grabs all formats, for all unstaged physical objects whose digitization_start timestamp is within 24 hrs of the specified date
  scope :unstaged_by_date_formats, lambda { |date|
    PhysicalObject.where(staging_requested: false).where(datesql(date)).pluck(:format)
  }

  # this scope grabs all physical objects of the specified format whose digital_start timestamp is within 24 hrs of the specified date
  scope :unstaged_by_date_by_format, lambda { |date, format|
    PhysicalObject.where(staging_requested: false, format: format).where(datesql(date)).order("RAND()")
  }

  # This scope selects all formats for unstaged physical objects on the specified date that have been digitized by Memnon
  scope :memnon_unstaged_by_date_formats, lambda{ |date|
    PhysicalObject.joins(:digital_provenance).where("staging_requested = false").where("digital_provenances.digitizing_entity = '#{DigitalProvenance::MEMNON_DIGITIZING_ENTITY}'").where(datesql(date)).pluck(:format)
  }
  # this scope grabs all unstaged physical objects of the specified format whose digital_start timestamp is with 24 hrs of the specified date
  # AND whose digitizing entity is Memnon
  scope :memnon_unstaged_by_date_and_format, lambda { |date, format|
    PhysicalObject.includes(:digital_statuses).joins(:digital_provenance).where(format: format,staging_requested: false).where("digital_provenances.digitizing_entity = '#{DigitalProvenance::MEMNON_DIGITIZING_ENTITY}'").where(datesql(date)).order("RAND()")
  }


  # This scope selects all formats for unstaged physical objects on the specified date that have been digitized by IU
  scope :iu_unstaged_by_date_formats, lambda{ |date|
    PhysicalObject.includes(:digital_statuses).joins(:digital_provenance).where(staging_requested: false).where("digital_provenances.digitizing_entity = '#{DigitalProvenance::IU_DIGITIZING_ENTITY}'").where(datesql(date)).pluck(:format)
  }
  # This scope selects all unstaged physical objects of the specified format, whose digital_start timestamp is within 24hrs of the specified date
  # AND whose digitizing entity is IU
  scope :iu_unstaged_by_date_and_format, lambda { |date, format|
    PhysicalObject.joins(:digital_provenance).where(format: format, staging_requested: false).where("digital_provenances.digitizing_entity = '#{DigitalProvenance::IU_DIGITIZING_ENTITY}'").where(datesql(date)).order("RAND()")
  }


  attr_accessor :generation_values
  def generation_values
    GENERATION_VALUES
  end

  def init_start_digital_status
    if ApplicationHelper.real_barcode?(self.mdpi_barcode)
      start = DigitalStatus.new(
        physical_object_id: self.id, 
        physical_object_mdpi_barcode: self.mdpi_barcode, 
        state: DigitalStatus::DIGITAL_STATUS_START, 
        message: "I'm starting!",
        options: nil,
        attention: false)
      self.digital_start = DateTime.now
      self.save
      start.save
    else
      raise "Cannot create a start digital status for PhysicalObject without a barcode"
    end
  end

  def group_identifier
    return "MISSING" if self.group_key.nil?
    self.group_key.group_identifier
  end

  def group_total
    return 1 if self.group_key.nil?
    self.group_key.group_total
  end

  def auto_accept
    digital_start ? (digital_start + auto_accept_days.days) : nil
  end

  def carrier_stream_index
    if self.group_key.nil?
      group_identifier + "_1_1"
    else
      self.group_key.group_identifier + "_" + self.group_position.to_s + "_" + self.group_key.group_total.to_s
    end
  end

  def active_blockers
    condition_statuses.select { |cs| cs.active and cs.condition_status_template.blocks_packing = true }
  end

  def container_id
    if !box.nil?
      box.id
    elsif !bin.nil?
      bin.id
    else
      nil
    end
  end

  # the passed in value for f should be the human readable name of the format - in the case of AnalogSoundDisc
  # technical metadatum, this could be LP/45/78/Lacquer Disc/etc
  def create_tm(format, tm_args = {})
    tm_class = TechnicalMetadatumModule.tm_format_classes[format]
    unless tm_class.nil?
      # setting the subtype should trigger and after_initialize callback to set defaults
      tm_args[:subtype] = format if TechnicalMetadatumModule.tm_subtypes.include?(format)
      tm_class.new(**tm_args)
    else
      raise "Unknown format: #{format}"
    end 
  end

  def file_prefix
    "MDPI_" + mdpi_barcode.to_s
  end

  def file_bext
    (file_iarl.blank? ? "" : file_iarl + " ") +
    (collection_identifier.blank? ? "" : collection_identifier + ". ") +
    (call_number.blank? ? "" : call_number + ". ") +
    "File use: "
  end

  def file_icmt
    file_bext
  end

  def file_iarl
    return "" if unit.nil?
    unit.home + ". " + unit.name + "."
  end

  def format_class
    return TechnicalMetadatumModule.tm_format_classes[self.format]
  end

  def self.to_csv(physical_objects, picklist = nil)
    CSV.generate do |csv|
      unless picklist.nil?
        csv << ["Picklist:", picklist.name]
      end
      if physical_objects.any?
        csv << physical_objects.first.printable_column_headers.map { |x| x.titleize }
        physical_objects.each do |physical_object|
          csv << physical_object.printable_row
        end
      end
    end
  end

  def digital_start_readable
    unless digital_start.nil?
      self.digital_start.strftime("%l:%M%P %B %-d, %Y")
    else
      "Digitization Has Not Begun"
    end
  end

  def expires
    start = self.digital_statuses.where("state='transferred'").order(created_at: :desc).first
    unless start.nil?
      start = start.created_at
      start += 40.days
    end
    start
  end

  def master_copies
    if self.technical_metadatum && self.technical_metadatum.specific
      self.technical_metadatum.specific.master_copies
    else
      0
    end
  end

  #manually add virtual attribute
  def printable_columns
    self.class.printable_columns
  end

  def self.printable_columns
    self.column_names + ['group_total']
  end
  
  def printable_attributes
    @printable_attributes = attributes
    @printable_attributes.each do |key, value|
      #look up descriptive values for associated objects
      if key =~ /_id$/
        if key.nil? || value.blank? || value.to_i.zero?
          @printable_attributes[key] = ""
        else
          @printable_attributes[key] = Kernel.const_get(key.titleize.gsub(' ', '')).find(value).spreadsheet_descriptor
        end
      end   
      #reset group key column value if needed
      @printable_attributes[key] = group_identifier if key == 'group_key_id' && value.blank?
    end
    @printable_attributes
  end

  def metadata_attributes
    technical_metadatum.specific.attributes
  end

  def metadata_columns
    technical_metadatum.specific.class.column_names
  end

  def printable_column_headers
    printable_columns + metadata_columns
  end

  def printable_row
    printable_attributes.values_at(*printable_columns) + metadata_attributes.values_at(*metadata_columns)
  end

  def workflow_blocked?
    condition_statuses.blocking.any?
  end

  def current_digital_status
    self.digital_statuses.last
  end
 
  # omit_picklisted Boolean adds search term to that effect
  def physical_object_query(omit_picklisted, results_limit = 0)
    symbolize = lambda { |h| h.inject({}){ |hash, (k,v)| hash.merge(k.to_sym => v) } }
    filter_blanks = lambda { |h| h.select{ |k,v| !v.to_s.blank? } }
    filter_forbidden = lambda { |h| h.delete_if { |k,v| k.in? [:id, :created_at, :updated_at, :physical_object_id] } }
    get_terms = lambda { |atts| filter_forbidden.call(symbolize.call(filter_blanks.call(atts))) }

    po_terms = get_terms.call(self.attributes)
    tm_terms = (self.ensure_tm ? get_terms.call(self.ensure_tm.attributes) : {})
    PhysicalObject.physical_object_search(omit_picklisted, po_terms, tm_terms, results_limit)
  end

  def ensure_tm
    if TechnicalMetadatumModule.tm_formats_hash[self.format]
      if self.technical_metadatum.nil? || self.technical_metadatum.specific.nil? || self.technical_metadatum.actable_type != TechnicalMetadatumModule.tm_format_classes[self.format].to_s
        @tm = create_tm(self.format, physical_object: self)
        #checks to ensure correct child/parent linkage for new objects; gem does not seem to take care of this?
        self.technical_metadatum = @tm.technical_metadatum if self.technical_metadatum != @tm.technical_metadatum
        self.technical_metadatum.actable = @tm if self.technical_metadatum.actable != @tm
        @tm
      else
        @tm = self.technical_metadatum.specific
      end
    end
  end

  def ensure_group_key
    self.group_key = GroupKey.new if self.group_key.nil?
    self.group_key
  end

  def ensure_digiprov
    self.digital_provenance ||= DigitalProvenance.new(physical_object_id: self.id) 
    self.digital_provenance
  end

  def display_workflow_status
    if self.current_workflow_status.in? ["Binned", "Boxed"]
      if self.bin
        bin_status = self.bin.display_workflow_status
      elsif self.box and self.box.bin
        bin_status = self.box.bin.display_workflow_status
      elsif !self.box and !self.bin
        bin_status = "(No bin or box assigned!)"
      end
    end
    bin_status = "" if bin_status.in? [nil, "Created"]
    addendum = ( bin_status.blank? ? "" : " >> #{bin_status}" )
    self.current_workflow_status.to_s + addendum
  end

  def inferred_workflow_status
    if self.current_workflow_status.in? ["Unpacked", "Returned to Unit"]
      return self.current_workflow_status
    elsif !self.bin.nil?
      return "Binned"
    elsif !self.box.nil?
      return "Boxed"
    elsif !self.picklist.nil?
      return "On Pick List"
    else
      return "Unassigned"
    end
  end

  def resolve_group_position
    unless self.group_key.nil?
      collisions = PhysicalObject.where(group_key_id: self.group_key_id, group_position: self.group_position).where.not(id: self.id).order(id: :asc)
      unless collisions.empty?
        #only resolve first collision, as cascade will fix others
        collisions[0].group_position += 1
        collisions[0].save
      end

      if self.group_position > self.group_key.group_total
        self.group_key.group_total = self.group_position
        self.group_key.save
      end
    end
  end

  def set_container_format
    if box && box.format.blank?
      box.format = format; box.save
    elsif bin && bin.format.blank?
      bin.format = format; bin.save
    end
  end

  def display_date_billed
    date_billed.in_time_zone.strftime("%m/%d/%Y")
  end

  def destroy_empty_group
    old_group_key = GroupKey.where(id: group_key_id_was).first
    if old_group_key
      old_group_key.destroy if old_group_key.physical_objects.count.zero?
    end
  end

  def condition_notes(include_metadata = false)
    active_conditions = self.condition_statuses.where(active: true).order(updated_at: :desc) 
    export_text = "" 
    active_conditions.each_with_index do |condition, index| 
      export_text += "#{condition.condition_status_template.name.upcase}: #{condition.notes}"
      export_text += " [#{condition.user}, #{condition.updated_at.in_time_zone.strftime("%Y-%m-%d %H:%M:%S")}]" if include_metadata
      export_text += " || " unless index == active_conditions.size - 1 
    end 
    return export_text
  end

  def other_notes(export_flag = true, include_metadata = false)
    export_notes = self.notes.where(export: export_flag).order(updated_at: :desc) 
    export_text = "" 
    export_notes.each_with_index do |note, index| 
      export_text += note.body
      export_text += " [#{note.user}, #{note.updated_at.in_time_zone.strftime("%Y-%m-%d %H:%M:%S")}]" if include_metadata
      export_text += " || " unless index == export_notes.size - 1 
    end
    return export_text
  end

  def validate_single_container_assignment
    errors[:base] << "You are attempting to directly assign this object to both a bin (#{bin.mdpi_barcode}) and a box (#{box.mdpi_barcode}), but an object can only be directly assigned to single container, at most." if bin && box
  end

  def validate_bin_container
    if bin
      if !ApplicationHelper.real_barcode?(self.mdpi_barcode)
        errors[:base] << "An object must be assigned a barcode before it can be assigned to a bin."
      elsif !self.format.in? TechnicalMetadatumModule.bin_formats
        errors[:base] << "Physical objects of format #{self.format} cannot be assigned to a bin."
      elsif bin.boxes.any?
        errors[:base] << "This bin (#{bin.mdpi_barcode}) contains boxes.  You may only assign a physical object to a bin containing physical objects."
      elsif !bin.format.blank? && bin.format != format
        errors[:base] << "This bin (#{bin.mdpi_barcode}) contains physical objects of a different format.  You may only assign a physical object to a bin containing the matching format (#{format})." 
      end
    end
  end

  def validate_box_container
    if box
      if !ApplicationHelper.real_barcode?(self.mdpi_barcode)
        errors[:base] << "An object must be assigned a barcode before it can be 
assigned to a box."
      elsif !self.format.in? TechnicalMetadatumModule.box_formats
        errors[:base] << "Physical objects of format #{self.format} cannot be assigned to a box."
      elsif !box.format.blank? && box.format != format
        errors[:base] << "This box (#{box.mdpi_barcode}) contains physical objects of a different format (#{box.format}).  You may only assign a physical object to a box containing the matching format (#{format})."
      end
    end
  end

  def validate_ephemera_values
    if self.ephemera_returned
      errors.add(:ephemera_returned, "cannot be checked if \"Has ephemera\" is unchecked.") unless self.has_ephemera
    end
  end

  def container_bin
    self.box ? self.box.bin : self.bin
  end


  def self.datesql(date)
    date.blank? ? "" : "DATEDIFF(physical_objects.digital_start, '#{date}') = 0"
  end

  # See DigitalFileProvenance::FILE_USE_VALUES for list of valid use codes
  def generate_filename(sequence: 1, use: 'pres', extension: nil)
    sequence ||= self.digital_provenance.digital_file_provenances.size + 1 if self.digital_provenance
    sequence = 1 unless sequence.to_i > 0
    use = 'pres' if use.to_s.blank?
    extension = TechnicalMetadatumModule::GENRE_EXTENSIONS[TechnicalMetadatumModule.tm_genres[self.format]] if extension.blank?
    "MDPI_#{self.mdpi_barcode}_#{sequence.to_s.rjust(2, "0")}_#{use}.#{extension}"
  end

  private
  # omit_picklisted Boolean adds search term to that effect
  # calling via physical_object_query on an individual object uses strong parameters filters,
  #  preventing SQL injection on 'name' values for LIKE case of string searches
  def self.physical_object_search(omit_picklisted, physical_object_terms, tm_terms, results_limit = 0)
    query_results = PhysicalObject.all
    query_results = query_results.where(physical_objects: { picklist_id: [0, nil] }) if omit_picklisted
    query_results = add_search_terms(query_results, :physical_objects, physical_object_terms)
    unless physical_object_terms[:format].blank? || tm_terms.empty?
      tm_table = tm_table_name(physical_object_terms[:format])
      tm_class = TechnicalMetadatumModule.tm_format_classes[physical_object_terms[:format]].to_s
      query_results = query_results.joins(:technical_metadatum).joins("INNER JOIN #{tm_table} ON technical_metadata.actable_id=#{tm_table}.id AND technical_metadata.actable_type='#{tm_class}'")
      query_results = add_search_terms(query_results, tm_table, tm_terms)
    end
    query_results = query_results.limit(results_limit) if results_limit > 0
    query_results
  end

  def self.add_search_terms(query_results, table_name, search_terms)
    # Database Boolean values also accept NULL, so match false to 0/NULL
    search_terms.each do |name, value|
      search_terms[name] = (value ? 1 : [0, nil]) if value.class.in? [TrueClass, FalseClass]
    end
    search_terms.each do |name, value|
      if value.class == String && value.include?('*')
        query_results = query_results.where("#{table_name}.#{name} LIKE ?", value.gsub(/[*]/, '%'))
      else
        query_results = query_results.where(table_name => { name => value })
      end
    end
    query_results
  end

  private
  def self.tm_table_name(format)
    table_name = TechnicalMetadatumModule.tm_table_names[format]
    unless table_name.nil?
      table_name
    else
      raise "Unknown format: #{format}"
    end
  end

  def tm_table_name(format)
    PhysicalObject.tm_table_name(format)
  end

  private 
  def default_values
    self.generation ||= ""
    self.group_position ||= 1
    self.mdpi_barcode ||= 0
    self.digital_provenance ||= DigitalProvenance.new(physical_object_id: self.id)
  end

end

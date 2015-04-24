class PhysicalObject < ActiveRecord::Base

  include WorkflowStatusModule
  extend WorkflowStatusQueryModule
  include ConditionStatusModule
  include ActiveModel::Validations
  include TechnicalMetadatumModule
  extend TechnicalMetadatumClassModule

  after_initialize :default_values
  after_initialize :assign_default_workflow_status
  before_validation :ensure_tm
  before_validation :ensure_group_key
  before_save :assign_inferred_workflow_status
  after_save :resolve_group_position

  belongs_to :box
  belongs_to :bin
  belongs_to :group_key
  belongs_to :picklist
  belongs_to :container
  belongs_to :spreadsheet
  belongs_to :unit
  
  has_one :technical_metadatum, :dependent => :destroy
  has_many :digital_files, :dependent => :destroy
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
  scope :following_for_packing, lambda { |po| where("call_number > ? or (call_number = ? and (group_key_id > ? or (group_key_id = ? and (group_position > ? or (group_position = ? and id > ?)))))", po.call_number, po.call_number, po.group_key_id, po.group_key_id, po.group_position, po.group_position, po.id) }
  scope :unpacked, lambda { where(bin_id: nil, box_id: nil) }
  scope :unpacked_or_id, lambda { |object_id| where("(bin_id is null and box_id is null) or id = ?", object_id) }
  scope :packed, lambda { where("physical_objects.bin_id > 0 OR physical_objects.box_id > 0") }
  scope :blocked, lambda { joins(:condition_statuses).where("condition_statuses.active is true and condition_statuses.condition_status_template_id in (?)", ConditionStatusTemplate.blocking_ids).includes(:condition_statuses) }

  # needs to be declared before the validation that uses it
  def self.formats
    TM_FORMATS
  end
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

  validates :format, presence: true, inclusion: { in: TM_FORMATS.keys, message: "value \"%{value}\" is not in list of valid values: #{TM_FORMATS.keys}" }
  validates :generation, inclusion: { in: GENERATION_VALUES.keys, message: "value \"%{value}\" is not in list of valid values: #{GENERATION_VALUES.keys}" }
  validates :group_position, presence: true
  validates :mdpi_barcode, mdpi_barcode: true
  validates :unit, presence: true
  validates :group_key, presence: true
  validates :technical_metadatum, presence: true
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

  scope :unstaged_by_date, lambda {|date|
    date_sql = date.nil? ? "" : "AND created_at > '#{date}'"
    PhysicalObject.find_by_sql(
      "SELECT physical_objects.*
      FROM physical_objects
      WHERE physical_objects.staged = false AND staging_requested = false AND physical_objects.id in 
      (
        SELECT physical_object_id
        FROM (
          SELECT max(id) as ds_id
          FROM digital_statuses
          WHERE state = '#{DigitalStatus::DIGITAL_STATUS_START}' #{date_sql}
          GROUP BY physical_object_id
        ) as ns_ids INNER JOIN digital_statuses as dses
        WHERE ns_ids.ds_id = dses.id
      )
      ORDER BY digital_start"
    )
  }

  # selects all physical objects whose staging_requested_timestamp is less than *hours_old*
  scope :staging_requested, lambda{|hours_old|
    PhysicalObject.find_by_sql(
      "SELECT *
      FROM physical_objects
      WHERE staging_requested = true AND staged = false "
    )
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
    tm_class = TM_FORMAT_CLASSES[format]
    unless tm_class.nil?
      # setting the subtype should trigger and after_initialize callback to set defaults
      tm_args[:subtype] = format if TM_SUBTYPES.include?(format)
      tm_class.new(**tm_args)
    else
      raise "Unknown format: #{format}"
    end 
  end

  def file_prefix
    "MDPI_" + mdpi_barcode.to_s
  end

  def file_bext
    file_iarl + " " +
    (collection_identifier.nil? ? "" : collection_identifier + ". ") +
    (call_number.nil? ? "" : call_number + ". ") +
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
    return TM_FORMAT_CLASSES[self.format]
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

  def master_copies
    if self.technical_metadatum && self.technical_metadatum.as_technical_metadatum
      self.technical_metadatum.as_technical_metadatum.master_copies
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
    technical_metadatum.as_technical_metadatum.attributes
  end

  def metadata_columns
    technical_metadatum.as_technical_metadatum.class.column_names
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
    DigitalStatus.where("physical_object_id = #{self.id}").order(:id).last
  end
  
  # omit_picklisted is a boolean specifying whether physical objects that have been added to
  # a picklist should be omitted from the search results
  def physical_object_query(omit_picklisted)
    sql = "SELECT physical_objects.* FROM physical_objects" << 
    (!format.nil? and format.length > 0 ? ", technical_metadata, #{tm_table_name(self.format)} " : " ") << 
    "WHERE " <<
    (!format.nil? and format.length > 0 ? 
      "physical_objects.format='#{format}' AND physical_objects.id=technical_metadata.physical_object_id " << 
      "AND technical_metadata.as_technical_metadatum_id=#{tm_table_name(self.format)}.id " 
      : 
      "" ) << (omit_picklisted ? "AND (picklist_id is null OR picklist_id = 0) " : "")
    physical_object_where_clause <<
    (!format.nil? and format.length > 0 ? technical_metadata_where_claus : "") 


    PhysicalObject.find_by_sql(sql)
  end

  def ensure_tm
    if TechnicalMetadatumModule::TM_FORMATS[self.format]
      if self.technical_metadatum.nil? || self.technical_metadatum.as_technical_metadatum.nil? || self.technical_metadatum.as_technical_metadatum_type != TechnicalMetadatumModule::TM_FORMAT_CLASSES[self.format].to_s
        self.technical_metadatum.destroy unless self.technical_metadatum.nil?
        @tm = create_tm(self.format, physical_object: self)
      else
        @tm = self.technical_metadatum.as_technical_metadatum
      end
    end
  end

  def ensure_group_key
    self.group_key = GroupKey.new if self.group_key.nil?
    self.group_key
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
      if !self.format.in? PhysicalObject.const_get(:BIN_FORMATS)
        errors[:base] << "Physical objects of format #{self.format} cannot be assigned to a bin."
      elsif bin.boxes.any?
        errors[:base] << "This bin (#{bin.mdpi_barcode}) contains boxes.  You may only assign a physical object to a bin containing physical objects."
      elsif bin.physical_objects.any? && bin.physical_objects.first.format != self.format
        errors[:base] << "This bin (#{bin.mdpi_barcode}) contains physical objects of a different format.  You may only assign a physical object to a bin containing the matching format (#{self.format})." 
      end
    end
  end

  def validate_box_container
    if box
      if !self.format.in? PhysicalObject.const_get(:BOX_FORMATS)
        errors[:base] << "Physical objects of format #{self.format} cannot be assigned to a box."
      elsif box.physical_objects.any? && box.physical_objects.first.format != self.format
        errors[:base] << "This box (#{box.mdpi_barcode}) contains physical objects of a different format.  You may only assign a physical object to a box containing the matching format (#{self.format})."
      end
    end
  end

  def validate_ephemera_values
    if self.ephemera_returned
      errors.add(:ephemera_returned, "cannot be checked if \"Has ephemera\" is unchecked.") unless self.has_ephemera
    end
  end

  private
  def physical_object_where_clause
    sql = " "
    self.attributes.each do |name, value|
      if name == 'id' or name == 'created_at' or name == 'updated_at' or name == 'has_ephemera' or name == "technical_metadatum"
        next
      elsif name =='mdpi_barcode' or name == 'iucat_barcode'
        unless value == 0 or value.nil?
          sql << " AND physical_objects.#{name}='#{value}'"
        end
      else
        if !value.nil? and (value.class == String and value.length > 0)
          operand = value.to_s.include?('*') ? ' like ' : '='
          v = value.to_s.include?('*') ? value.to_s.gsub(/[*]/, '%') : value
          sql << " AND physical_objects.#{name}#{operand}'#{v}'"
        elsif !value.nil? and value.class == TrueClass
          sql << " AND physical_objects.#{name}=1"
        end
      end
    end
    sql
  end

  private
  def technical_metadata_where_claus
    tm_where(tm_table_name(format), technical_metadatum.as_technical_metadatum)
  end

  private
  def tm_table_name(format)
    table_name = TM_TABLE_NAMES[format]
    unless table_name.nil?
      table_name
    else
      raise "Unknown format: #{format}"
    end
  end

  private 
  def default_values
    self.generation ||= ""
    self.group_position ||= 1
    self.mdpi_barcode ||= 0
  end

  # def open_reel_tm_where(stm)
  #   q = ""
  #   stm.attributes.each do |name, value|
  #     #ignore these fields in the Sql WHERE clause
  #     if name == 'id' or name == 'created_at' or name == 'updated_at' or name == "as_technical_metadatum_type"
  #       next
  #     # a value of false in a query means we don't care whether the returned value is true OR false
  #     elsif !value.nil? and (value.class == String and value.length > 0)
  #       q << " AND open_reel_tms.#{name}='#{value}'"
  #     elsif !value.nil? and value.class == TrueClass
  #       q << " AND open_reel_tms.#{name}=1"
  #     end
  #   end
  #   q
  # end

  def tm_where(table_name, tm)
    q = ""
    tm.attributes.each do |name, value|
      #ignore these fields in the Sql WHERE clause
      if name == 'id' or name == 'created_at' or name == 'updated_at' or 
      name == "as_technical_metadatum_type" or name == 'unknown' or name == 'none'
        next
      # a value of false in a query means we don't care whether the returned value is true OR false
      elsif !value.nil? and (value.class == String and value.length > 0)
        q << " AND #{table_name}.#{name}='#{value}'"
      elsif !value.nil? and value.class == TrueClass
        q << " AND #{table_name}.#{name}=1"
      end
    end
    q
  end

end

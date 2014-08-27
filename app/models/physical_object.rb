class PhysicalObject < ActiveRecord::Base

  include WorkflowStatusModule
  include ConditionStatusModule
  include ActiveModel::Validations
  include TechnicalMetadatumModule

  after_initialize :default_values
  after_initialize :assign_default_workflow_status

  belongs_to :box
  belongs_to :bin
  belongs_to :group_key, counter_cache: true
  belongs_to :picklist
  belongs_to :container
  belongs_to :unit
  
  has_one :technical_metadatum, :dependent => :destroy
  has_many :digital_files, :dependent => :destroy
  has_many :workflow_statuses, :dependent => :destroy
  has_many :condition_statuses, :dependent => :destroy
  has_many :notes, :dependent => :destroy

  accepts_nested_attributes_for :condition_statuses, allow_destroy: true
  accepts_nested_attributes_for :notes, allow_destroy: true

  # needs to be declared before the validation that uses it
  def self.formats
    TM_FORMATS
  end
  validates_presence_of :format, inclusion: formats.keys
  validates :group_position, presence: true
  validates :mdpi_barcode, mdpi_barcode: true
  validates_presence_of :unit
  validates_with PhysicalObjectValidator

  accepts_nested_attributes_for :technical_metadatum
  scope :search_by_catalog, lambda {|query| where(["call_number = ?", query, query])}
  scope :search_by_barcode, lambda {|barcode| where(["mdpi_barcode = ? OR iucat_barcode = ?", barcode, barcode])}
  scope :search_id, lambda {|i| 
    where(['mdpi_barcode = ? OR iucat_barcode = ? OR call_number like ?', i, i, i, i])
  }
  scope :advanced_search, lambda {|po| 
    po.physical_object_query(false)
  }

  # this hash holds the human reable attribute name for this class
  HUMANIZED_COLUMNS = {
      :mdpi_barcode => "MDPI barcode",
      :iucat_barcode => "IUCAT barcode",
      :oclc_number => "OCLC number"
  }

  #manually add virtual attributes to @attributes
  def attributes
    @attributes['group_total'] = group_total
    @attributes
  end

  def group_identifier
    "GR" + id.to_s.rjust(8, "0") 
  end

  def group_total
    return 1 if self.group_key.nil?
    return self.group_key.physical_objects_count
  end

  def carrier_stream_index
    if self.group_key.nil?
      group_identifier + "_1_1"
    else
      self.group_key.group_identifier + "_" + self.group_position.to_s + "_" + self.group_key.physical_objects_count.to_s
    end
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

  def create_tm(f)
    tm_class = TM_FORMAT_CLASSES[f]
    unless tm_class.nil?
      tm_class.new
    else
      raise 'Unknown format type' + format
    end 
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
          csv << ["test row"]
        end
      end
    end
  end

  #manually add virtual attribute
  def printable_columns
    self.class.printable_columns
  end

  def self.printable_columns
    @column_names = column_names
    @column_names << 'group_total' unless @column_names.include?('group_total')
    @column_names
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

class PhysicalObject < ActiveRecord::Base
  
  include WorkflowStatusModule
  include ConditionStatusModule
  include ActiveModel::Validations

  after_initialize :default_values
 
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

  accepts_nested_attributes_for :condition_statuses, allow_destroy: true

  # needs to be declared before the validation that uses it
  def self.formats
    {
      "CD-R" => "CD-R",
      "DAT" => "DAT",
      "Open Reel Audio Tape" => "Open Reel Audio Tape"
    }
  end
  validates_presence_of :format, inclusion: formats.keys
  validates :group_position, presence: true
  validates :mdpi_barcode, mdpi_barcode: true
  validates_presence_of :unit
  validates_with PhysicalObjectValidator

  after_initialize :init
  after_create :create

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

  # overridden to provide for more human readable attribute names for things like :mdpi_barcode (so that mdpi is MDPI)
  def self.human_attribute_name(*attribute)
    HUMANIZED_COLUMNS[attribute[0].to_sym] || super
  end

  def init
    self.mdpi_barcode ||= 0
  end

  def create
    default_status = WorkflowStatusQueryModule.default_status(self)
    self.workflow_statuses << default_status
  end

  def group_identifier
    "GR" + id.to_s.rjust(8, "0") 
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
    if f == "Open Reel Audio Tape"
      OpenReelTm.new
    elsif f == 'CD-R'
      CdrTm.new
    elsif f == 'DAT'
      DatTm.new
    else
      raise 'Unknown format type' + format
    end 
  end

  def format_class
    if format == "OpenReelTm"
      OpenReelTm.class
    end
  end

  def self.to_csv(physical_objects)
    CSV.generate do |csv|
      if physical_objects.any?
        md_columns = physical_objects.first.technical_metadatum.as_technical_metadatum.class.column_names
	csv << column_names + md_columns
        physical_objects.each do |physical_object|
          csv << physical_object.attributes.values_at(*column_names) + physical_object.technical_metadatum.as_technical_metadatum.attributes.values_at(*md_columns)
        end
      end
    end
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
    if format == "Open Reel Audio Tape"
      "open_reel_tms"
    elsif format == "CD-R"
      "cdr_tms"
    elsif format == "DAT"
      "dat_tms"
    else
      raise "Unsupported format: #{format}"
    end
  end

  private 
  def default_values
    self.group_position ||= 1
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

class PhysicalObject < ActiveRecord::Base
  
  include WorkflowStatusModule
  include ConditionStatusModule
  include ActiveModel::Validations
 
  belongs_to :box
  belongs_to :bin
  belongs_to :picklist
  belongs_to :container
  has_one :technical_metadatum
  has_many :digital_files
  has_many :workflow_statuses
  has_many :condition_statuses
  accepts_nested_attributes_for :condition_statuses, allow_destroy: true
  
  validates_presence_of :unit
  # needs to be declared before the validation that uses it
  def self.formats
    {
      "CD-R" => "CD-R",
      "DAT" => "DAT",
      "Open Reel Tape" => "Open Reel Tape"
    }
  end
  validates_presence_of :format, inclusion: formats.keys
  validates :mdpi_barcode, mdpi_barcode: true
  validates_with PhysicalObjectValidator

  after_initialize :init

  accepts_nested_attributes_for :technical_metadatum
  scope :search_by_catalog, lambda {|query| where(["call_number = ?", query, query])}
  scope :search_by_barcode, lambda {|barcode| where(["mdpi_barcode = ? OR iucat_barcode = ?", barcode, barcode])}
  scope :search_id, lambda {|i| 
    where(['mdpi_barcode = ? OR iucat_barcode = ? OR call_number like ?', i, i, i, i])
  }
  scope :advanced_search, lambda {|po| 
    po.physical_object_query
    #PhysicalObject.find_by_sql(po.physical_object_query)
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
    if f == "Open Reel Tape"
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

  def physical_object_query
    sql = "SELECT physical_objects.* FROM physical_objects" << 
    (!format.nil? and format.length > 0 ? ", technical_metadata, #{tm_table_name(self.format)} " : " ") << 
    "WHERE " <<
    (!format.nil? and format.length > 0 ? 
      "physical_objects.id=technical_metadata.physical_object_id " << 
      "AND technical_metadata.as_technical_metadatum_id=#{tm_table_name(self.format)}.id " 
      : 
      "" ) <<
    physical_object_where_clause <<
    (!format.nil? and format.length > 0 ? technical_metadata_where_claus : "") 

    PhysicalObject.find_by_sql(sql)
  end

  private
  def physical_object_where_clause
    sql = " "
    self.attributes.each do |name, value|
      if name == 'id' or name == 'created_at' or name == 'updated_at' or name == 'has_ephemira' or name == "technical_metadatum"
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
    if format == "Open Reel Tape"
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

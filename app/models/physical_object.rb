class PhysicalObject < ActiveRecord::Base

  has_one :technical_metadatum
  belongs_to :bin
  has_many :workflow_statuses
  

  attr_accessor :formats 
  def formats
    {"Cassette Tape" => "Cassette Tape", "Compact Disc" => "Compact Disc", "LP" => "LP", "Open Reel Tape" => "Open Reel Tape"}
  end

  accepts_nested_attributes_for :technical_metadatum

  scope :search_by_catalog, lambda {|query| where(["shelf_number = ? OR call_number = ?", query, query])}
  
  scope :search_by_barcode, lambda {|barcode| where(["memnon_barcode = ? OR iu_barcode = ?", barcode, barcode])}
  
  scope :search_id, lambda {|i| 
    where(['memnon_barcode like ? OR iu_barcode like ? OR shelf_number like ? OR call_number like ?', i, i, i, i])
  }
  
  def splitable?(s="")
    s.include? "-" or s.include? ","
  end

  def init_tm
    if format == "Cassette Tape"
      ctm = CassetteTapeTm.new
      ctm.physical_object = self
      ctm.save
    elsif format == "Compact Disc"
      cdtm = CompactDiscTm.new
      cdtm.physical_object = self
      cdtm.save
    elsif format == "LP"
      lptm = LpTm.new
      lptm.physical_object = self
      lptm.save
    elsif format == "Open Reel Tape"
      ortm = OpenReelTm.new
      ortm.physical_object = self
      ortm.save
    else
      raise 'Unknown format type' + format
    end 
      
  end
end

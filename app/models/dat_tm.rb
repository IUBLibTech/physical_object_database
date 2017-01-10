class DatTm < ActiveRecord::Base
  acts_as :technical_metadatum, validates_actable: false
  #no default values needed
  extend TechnicalMetadatumClassModule
  # TM module constants
  # PROVENANCE_REQUIREMENTS unchanged from default
  TM_FORMAT = ['DAT']
  TM_SUBTYPE = false
  TM_GENRE = :audio
  TM_PARTIAL = 'show_dat_tm'
  BOX_FORMAT = true
  BIN_FORMAT = false
  # TM simple fields
  SIMPLE_FIELDS = ["format_duration", "tape_stock_brand"]
  # TM Boolean fieldsets
  SAMPLE_RATE_FIELDS = ["sample_rate_32k", "sample_rate_44_1_k", "sample_rate_48k", "sample_rate_96k"]
  PRESERVATION_PROBLEM_FIELDS = ["fungus", "soft_binder_syndrome", "other_contaminants"]
  MULTIVALUED_FIELDSETS = {
    "Sample rate" => :SAMPLE_RATE_FIELDS,
    "Preservation problems" => :PRESERVATION_PROBLEM_FIELDS
  }
  # TM display and export
  FIELDSET_COLUMNS = {
    "Sample rate" => 2,
    "Preservation problems" => 2
  }
  HUMANIZED_COLUMNS = {
      :sample_rate_32k => "32k",
      :sample_rate_44_1_k => "44.1k",
      :sample_rate_48k => "48k",
      :sample_rate_96k => "96k"
  }
  MANIFEST_EXPORT = {
    "Sample rate" => :SAMPLE_RATE_FIELDS,
    "Cassette length" => :format_duration
  }
  include TechnicalMetadatumModule

  # no default_values

  # no additional values needed
  def default_values_for_upload
  end

  def damage
    return ""
  end

  # master_copies default of 1

  alias_method :sample_rates, :sample_rate

end

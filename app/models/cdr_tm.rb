class CdrTm < ActiveRecord::Base
  acts_as :technical_metadatum, validates_actable: false
  after_initialize :default_values, if: :new_record?
  extend TechnicalMetadatumClassModule
  # TM module constants
  # PROVENANCE_REQUIREMENTS unchanged from default
  TM_FORMAT = ['CD-R']
  TM_SUBTYPE = false
  TM_GENRE = :audio
  TM_PARTIAL = 'show_cdr_tm'
  BOX_FORMAT = true
  BIN_FORMAT = false
  # TM simple fields
  SIMPLE_FIELDS = ["damage", "format_duration"]
  DAMAGE_VALUES = hashify ["None", "Minor", "Moderate", "Severe"]
  FORMAT_DURATION_VALUES = hashify ["", "74 min", "80 min", "90 min", "99 min", "Unknown"]
  # TM Boolean fieldsets
  PRESERVATION_PROBLEM_FIELDS = ["breakdown_of_materials", "fungus", "other_contaminants"]
  MULTIVALUED_FIELDSETS = {
    "Preservation problems" => :PRESERVATION_PROBLEM_FIELDS
  }
  # TM display and export
  FIELDSET_COLUMNS = {
    "Preservation problems" => 2
  }
  HUMANIZED_COLUMNS = {}
  MANIFEST_EXPORT = {}
  include TechnicalMetadatumModule

  def default_values
    self.damage ||= "None"
    self.format_duration ||= "Unknown"
  end

  def default_values_for_upload
     default_values
  end

  # damage field

  # master_copies default of 1
end

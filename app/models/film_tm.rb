class FilmTm < ActiveRecord::Base
  acts_as :technical_metadatum, validates_actable: false
  after_initialize :default_values, if: :new_record?
  extend TechnicalMetadatumClassModule
  # TM module constants
  # PROVENANCE_REQUIREMENTS unchanged from default
  TM_FORMAT = ['Film']
  TM_SUBTYPE = false
  TM_GENRE = :film
  TM_PARTIAL = 'show_generic_tm'
  BOX_FORMAT = false
  BIN_FORMAT = true
  # TM simple fields
  SIMPLE_FIELDS = ['gauge']
  GAUGE_VALUES = hashify ['8mm', 'super 8mm', '9.5mm', '16mm', 'super 16mm', '28mm', '35mm', '35/32mm', '70mm']
  # TM Boolean fieldsets
  PRESERVATION_PROBLEM_FIELDS = []
  MULTIVALUED_FIELDSETS = {}
  # TM display and export
  FIELDSET_COLUMNS = {}
  HUMANIZED_COLUMNS = {}
  MANIFEST_EXPORT = {}
  include TechnicalMetadatumModule

  def default_values
  end

  def default_values_for_upload
     default_values
  end

  # damage field
  def damage
    ''
  end

  # master_copies default of 1
end

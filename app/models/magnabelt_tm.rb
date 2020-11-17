class MagnabeltTm < ActiveRecord::Base
  acts_as :technical_metadatum, validates_actable: false
  after_initialize :default_values, if: :new_record?
  extend TechnicalMetadatumClassModule
  # TM module constants
  DIGITAL_PROVENANCE_FILES = ['Digital Master', 'PresInt']
  # PROVENANCE_REQUIREMENTS unchanged from default
  TM_FORMAT = ['Magnabelt']
  TM_SUBTYPE = false
  TM_GENRE = :audio
  TM_PARTIAL = 'show_generic_tm'
  BOX_FORMAT = false
  BIN_FORMAT = true
  # TM simple fields
  SIMPLE_FIELDS = %w(size stock_brand damage)
  SIZE_VALUES = hashify(%w[3-inch 4-inch])
  DAMAGE_VALUES = hashify(%w[None Minor Moderate Severe])
  # TM Boolean fieldsets - none
  MULTIVALUED_FIELDSETS = {}
  # TM display and export
  FIELDSET_COLUMNS = {}
  HUMANIZED_COLUMNS = {}
  # no preservation problems
  MANIFEST_EXPORT = {
    'Size' => :size,
    'Stock brand' => :stock_brand,
  }
  include TechnicalMetadatumModule

  def default_values
    self.size = '4-inch'
    self.damage = 'None'
  end

  def default_values_for_upload
    default_values
  end

  # damage field

  # master_copies default of 1
end

class ProcessingStep < ActiveRecord::Base
  belongs_to :signal_chain
  belongs_to :machine
  validates :signal_chain, presence: true
  validates :machine, presence: true
  validates :position, presence: true, numericality: { greater_than: 0 }, uniqueness: { scope: :signal_chain }
  validate :validate_format_compatibility
  default_scope { order(:signal_chain_id, :position) }

  def validate_format_compatibility
    if signal_chain && machine
      errors[:base] << "None of the formats supported by this signal chain (#{signal_chain.formats}) are supported by the chosen machine (#{machine.formats})" if (signal_chain.formats & machine.formats).empty?
    end
  end
end

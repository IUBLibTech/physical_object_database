class ProcessingStep < ActiveRecord::Base
  belongs_to :signal_chain
  belongs_to :machine
  validates :signal_chain, presence: true
  validates :machine, presence: true
  validates :position, presence: true, numericality: { greater_than: 0 }, uniqueness: { scope: :signal_chain }
  default_scope { order(:signal_chain_id, :position) }
end

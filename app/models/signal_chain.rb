class SignalChain < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  default_scope { order(:name) }
  has_many :processing_steps, dependent: :destroy
  has_many :machines, through: :processing_steps
  has_many :signal_chain_formats

  def formats
    signal_chain_formats.map { |scf| scf.format }
  end
end

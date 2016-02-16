class SignalChain < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  default_scope { order(:name) }
  has_many :processing_steps, dependent: :destroy
  has_many :machines, through: :processing_steps
  has_many :signal_chain_formats, dependent: :destroy
  has_many :digital_file_provenances, dependent: :restrict_with_error
  accepts_nested_attributes_for :signal_chain_formats, allow_destroy: true

  def formats
    signal_chain_formats.map { |scf| scf.format }
  end
end

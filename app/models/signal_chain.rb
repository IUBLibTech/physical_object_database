class SignalChain < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  default_scope { order(:name) }
  has_many :processing_steps
  has_many :machines, through: :processing_steps
end

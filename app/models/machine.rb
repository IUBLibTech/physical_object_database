class Machine < ActiveRecord::Base
  validates :category, presence: true
  validates :serial, presence: true
  default_scope { order(:category, :serial, :manufacturer, :model) }
  has_many :processing_steps
  has_many :signal_chains, through: :processing_steps
end

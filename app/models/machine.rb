class Machine < ActiveRecord::Base
  validates :category, presence: true
  validates :serial, presence: true
  default_scope { order(:category, :serial, :manufacturer, :model) }
end

class MachineFormat < ActiveRecord::Base
  belongs_to :machine
  validates :machine, presence: true
  validates :format, presence: true, uniqueness: { scope: :machine }
end

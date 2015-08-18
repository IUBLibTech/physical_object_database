class Machine < ActiveRecord::Base
  validates :category, presence: true
  validates :serial, presence: true
  default_scope { 
  	# FIXME:
  	# this order interferes with the processing_steps position order, but I think that removing this
  	# simply results in the order of machines in a device chain being the id order of the machine
  	# order(:category, :serial, :manufacturer, :model) 
  }
  has_many :processing_steps
  has_many :signal_chains, through: :processing_steps

  def full_name
  	"[#{self.category}] #{self.manufacturer} #{self.model} - #{self.serial}"
  end
end

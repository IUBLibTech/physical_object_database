class Machine < ActiveRecord::Base
  validates :category, presence: true
  validates :serial, presence: true
  default_scope lambda { 
  	# FIXME:
  	# this order interferes with the processing_steps position order, but I think that removing this
  	# simply results in the order of machines in a device chain being the id order of the machine
  	# order(:category, :serial, :manufacturer, :model) 
  }
  has_many :processing_steps, dependent: :restrict_with_error
  has_many :signal_chains, through: :processing_steps
  has_many :machine_formats, dependent: :destroy
  accepts_nested_attributes_for :machine_formats, allow_destroy: true

  def full_name
  	"[#{self.category}] #{self.manufacturer} #{self.model} - #{self.serial}"
  end

  def formats
    machine_formats.map { |mf| mf.format }
  end
end

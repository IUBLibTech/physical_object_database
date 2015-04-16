require 'singleton'

module DigitalFileAutoAcceptor
	include Singleton

	def initialize
		
	end

	def start
		thread.new {
			DigitalStatus.connection.execute(
				"SELECT "
			)
		}
	end

end

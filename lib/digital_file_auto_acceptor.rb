require 'singleton'

class DigitalFileAutoAcceptor
	include Singleton

	ELEVEN = 23 * 60
	MIDNIGHT = 24 * 60

	def aa_logger
		@@aa_logger ||= Logger.new("#{Rails.root}/log/auto_accept.log")
	end

	def start
		Thread.new {
			while true
				# approximate waking the thread up around midnight
				time = Time.now
				aa_logger.info("Auto accept thread running at #{time}")
				mins = total_mins(time)
				if ELEVEN <= mins and mins <= MIDNIGHT
					auto_accept
				end
				# recalc time in case auto_accept ran for awhile
				time = Time.now
				mins = total_mins(time)
				sleep (mins < MIDNIGHT ? (MIDNIGHT - mins) * 60 : 0) + (ELEVEN * 60)
			end
		}
	end

	def total_mins(time)
		hr = time.hour + 1
		return time.min + (hr * 60)
	end

	def auto_accept
		audio = DigitalStatus.expired_audio_physical_objects
		audio.each do |po|
			if po.current_digital_status.state == 'qc_wait'
				po.current_digital_status.update_attributes(decided: 'to_distribute')
			else
				po.current_digital_status.update_attributes(decided: 'to_archive')
			end
			aa_logger.info("Auto accepting #{po.mdpi_barcode}, #{po.current_digital_status.state} -> #{po.current_digital_status.decided}")
		end
	end


end

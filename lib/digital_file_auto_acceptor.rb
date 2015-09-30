require 'singleton'

class DigitalFileAutoAcceptor
	include Singleton

	ELEVEN = 23 * 60
	MIDNIGHT = 24 * 60

	def aa_logger
		@@aa_logger ||= Logger.new("#{Rails.root}/log/auto_accept.log")
	end

	def start
		aa_logger.info("Auto accept thread started at #{Time.now}")
		Thread.new {
			while true
				# approximate waking the thread up around midnight
				time = Time.now
				mins = total_mins(time)
				if ELEVEN <= mins && mins <= MIDNIGHT
					aa_logger.info("Auto accept thread running at #{time} (#{mins})")
					begin
						auto_accept
					rescue Exception => e
						aa_logger.info("EXCEPTION: #{e.inspect}")
					end
				else
					aa_logger.info("Auto accept thread skipped at #{time} (#{mins})")
				end
				# recalc time in case auto_accept ran for awhile
				time = Time.now
				mins = total_mins(time)
				sleep_duration = (ELEVEN * 60) + (mins < MIDNIGHT ? (MIDNIGHT - mins) * 60 : 0)
				aa_logger.info("Sleeping for #{sleep_duration} until #{Time.now + sleep_duration}")
				sleep(sleep_duration)
			end
		}
	end

	def total_mins(time)
		(time.hour * 60) + time.min
	end

	def auto_accept
		audio = DigitalStatus.expired_audio_physical_objects
		aa_logger.info("Expired audio objects: #{audio.size}")
		audio.each do |po|
			if po.current_digital_status.state == 'qc_wait'
				po.current_digital_status.update_attributes(decided: 'qc_passed')
			else
				po.current_digital_status.update_attributes(decided: 'to_archive')
			end
			aa_logger.info("Auto accepting #{po.mdpi_barcode}, #{po.current_digital_status.state} -> #{po.current_digital_status.decided}")
		end
		video = DigitalStatus.expired_video_physical_objects
		aa_logger.info("Expired video objects: #{video.size}")
		video.each do |po|
			if po.current_digital_status.state == 'qc_wait'
				po.current_digital_status.update_attributes(decided: 'qc_passed')
			else
				po.current_digital_status.update_attributes(decided: 'to_archive')
			end
			aa_logger.info("Auto accepting #{po.mdpi_barcode}, #{po.current_digital_status.state} -> #{po.current_digital_status.decided}")
		end
	end


end

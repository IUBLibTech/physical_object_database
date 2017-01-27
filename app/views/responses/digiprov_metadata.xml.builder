xml.instruct! :xml, :version=>"1.0"

xml.pod("xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance") do
   if @success
     xml.success true
     xml.data do
       #physical_object source
       xml.format @physical_object.format
       xml.call_number @physical_object.call_number
       xml.title @physical_object.title
       xml.unit @physical_object.unit.name
       xml.mdpi_barcode @physical_object.mdpi_barcode
       xml.file_iarl @physical_object.file_iarl.sub(/\.$/,'')
       xml.file_icmt @physical_object.file_icmt
       xml.file_bext @physical_object.file_bext
       #digital_provenance source
       xml.digitizing_entity @dp.digitizing_entity
       @dp.attributes.keys.each do |att|
         @dp[att] = nil if @tm.provenance_requirements[att.to_sym].nil?
       end
       if @dp.baking
         xml.baking_date @dp.baking.in_time_zone.in_time_zone("UTC").strftime("%Y-%m-%dT%H:%M:%SZ")
       else
         xml.baking_date("xsi:nil" => "true")
       end
       if @dp.cleaning_date
         xml.cleaning_date @dp.cleaning_date.in_time_zone.in_time_zone("UTC").strftime("%Y-%m-%dT%H:%M:%SZ")
       else
         xml.cleaning_date("xsi:nil" => "true")
       end
       xml.cleaning_comment @dp.cleaning_comment
       xml.repaired @dp.repaired
       xml.comments @dp.comments
       #tm source
       xml.damage @tm.damage.gsub(', ',',')
       xml.preservation_problems @tm.preservation_problems.gsub(', ',',')
       xml.directions_recorded (@tm.respond_to?(:directions_recorded) ? @tm.directions_recorded : "")
       xml.sound_field (@tm.respond_to?(:sound_field) ? @tm.sound_field : "").gsub(', ',',')
       xml.tape_stock_brand (@tm.respond_to?(:tape_stock_brand) ? @tm.tape_stock_brand : "")
       xml.tape_thickness (@tm.respond_to?(:tape_thickness) ? @tm.tape_thickness : "").gsub(', ',',')
       xml.tape_base (@tm.respond_to?(:tape_base) ? @tm.tape_base : "").gsub(', ',',')
       xml.track_configuration (@tm.respond_to?(:track_configuration) ? @tm.track_configuration : "").gsub(', ',',')
       if @tm.respond_to?(:playback_speed)
	 xml.playback_speed @tm.playback_speed.gsub(', ',',')
       elsif @tm.respond_to?(:speed)
	 xml.playback_speed @tm.speed + (@tm.speed.blank? ? "" : " rpm")
       else
	 xml.playback_speed ""
       end
       xml.image_format (@tm.respond_to?(:image_format) ? @tm.image_format : "").gsub(', ',',')
       xml.recording_standard (@tm.respond_to?(:recording_standard) ? @tm.recording_standard : "").gsub(', ',',')
       xml.format_version (@tm.respond_to?(:format_version) ? @tm.format_version : "").gsub(', ',',')
       #dfp
       xml.digital_files do
         @dp.digital_file_provenances.order(:filename).each do |dfp|
           dfp.attributes.keys.each do |att|
             dfp[att] = nil if (@tm.provenance_requirements[att.to_sym].nil? && !(att.to_sym.in? [:digital_provenance_id, :filename]))
           end
           xml.digital_file_provenance do
             xml.filename dfp.filename
             if dfp.date_digitized
               xml.date_digitized dfp.date_digitized.in_time_zone("UTC").strftime("%Y-%m-%dT%H:%M:%SZ")
             else
               xml.date_digitized("xsi:nil" => "true")
             end
             xml.comment dfp.comment.to_s
             xml.created_by dfp.created_by.to_s
             xml.speed_used dfp.speed_used.to_s
             xml.tape_fluxivity dfp.tape_fluxivity.to_s + (dfp.tape_fluxivity.blank? ? "" : " nWb/m")
             xml.volume_units dfp.volume_units.to_s + (dfp.volume_units.blank? ? "" : " dB")
             xml.analog_output_voltage dfp.analog_output_voltage.to_s + (dfp.analog_output_voltage.blank? ? "" : " dBu")
             xml.peak dfp.peak.to_s + (dfp.peak.blank? ? "" : " dBfs")
             xml.stylus_size dfp.stylus_size.to_s
             xml.turnover dfp.turnover.to_s
             xml.rolloff dfp.rolloff.to_s
             xml.rumble_filter dfp.rumble_filter.to_s
             xml.reference_tone_frequency dfp.reference_tone_frequency.to_s
             xml.signal_chain do
               unless dfp.signal_chain.nil?
                 dfp.signal_chain.processing_steps.each do |device|
                   xml.device do
                     xml.device_type device.machine.category.to_s
                     xml.serial_number device.machine.serial.to_s
                     xml.manufacturer device.machine.manufacturer.to_s
                     xml.model device.machine.model.to_s
                   end
                 end
               end
             end
             xml.digital_file_bext dfp.digital_file_bext
           end
         end
       end
     end
   else
     xml.success false
     xml.message @message
   end
end

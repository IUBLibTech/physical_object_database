xml.instruct! :xml, :version=>"1.0"

xml.pod("xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance") do
  if @success
    xml.success true
    xml.data do
      xml.object("xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance") do
        xml.basics do
          xml.format @physical_object.format
          xml.files @physical_object.ensure_tm.master_copies
        end
        xml.assignment do
          xml.unit @physical_object.unit.abbreviation
          xml.group_key @physical_object.group_key.group_identifier
          xml.picklist @physical_object.picklist.name if @physical_object.picklist
          if @physical_object.bin
            xml.bin @physical_object.bin.mdpi_barcode
            xml.batch @physical_object.bin.batch.identifier if @physical_object.bin.batch
          elsif @physical_object.box
            xml.box @physical_object.box.mdpi_barcode
            if @physical_object.box.bin
              xml.bin @physical_object.box.bin.mdpi_barcode
              xml.batch @physical_object.box.bin.batch.identifier if @physical_object.box.bin.batch
            end
          end
          xml.spreadsheet @physical_object.spreadsheet.filename if @physical_object.spreadsheet
        end
        xml << @physical_object.to_xml(skip_instruct: true, skip_types: true, dasherize: false, root: :details, include: [:workflow_statuses, :notes, :condition_statuses]).gsub(/^/, '      ').gsub('nil="true"', 'xsi:nil="true"')
        xml << @tm.to_xml(format: @physical_object.format, skip_instruct: true, skip_types: true, dasherize: false, root: :technical_metadata).gsub(/^/, '      ')
        xml.digital_provenance do
          dp = @physical_object.digital_provenance
          dp.attributes.each do |k,v|
            if v.nil?
              dp.send((k.to_s + "=").to_sym, "")
              dp.send((k.to_s + "=").to_sym, false) if dp.send(k).nil?
            end
          end
          xml.digitizing_entity dp.digitizing_entity
          xml.comments dp.comments
          if dp.cleaning_date
            xml.cleaning_date dp.cleaning_date.to_s.sub(" ", "T").sub(" ","").sub("0400", "04:00")
          else
            xml.cleaning_date("xsi:nil" => "true")
          end
          if dp.baking
            xml.baking dp.baking.to_s.sub(" ", "T").sub(" ","").sub("0400", "04:00")
          else
            xml.baking("xsi:nil" => "true")
          end
          xml.repaired dp.repaired
          xml.cleaning_comment dp.cleaning_comment
          xml.digitization_time dp.duration
          xml.digital_files do
            dp.digital_file_provenances.each do |dfp|
              xml.digital_file_provenance do
                xml.filename dfp.filename
                if dfp.date_digitized
                  xml.date_digitized dfp.date_digitized.to_s.sub(" ", "T").sub(" ","").sub("0400", "04:00").sub("0500", "05:00")
                else
                  xml.date_digitized("xsi:nil" => "true")
                end
                xml.comment dfp.comment
                xml.created_by dfp.created_by
                xml.speed_used dfp.speed_used
                xml.tape_fluxivity dfp.tape_fluxivity
                xml.volume_units dfp.volume_units
                xml.analog_output_voltage dfp.analog_output_voltage
                xml.peak dfp.peak
                xml.stylus_size dfp.stylus_size
                xml.turnover dfp.turnover
                xml.rolloff dfp.rolloff
                xml.rumble_filter dfp.rumble_filter
                xml.reference_tone_frequency dfp.reference_tone_frequency
                xml.signal_chain do
                  unless dfp.signal_chain.nil?
                    dfp.signal_chain.processing_steps.each do |device|
                      xml.device do
                        xml.device_type device.machine.category
                        xml.serial_number device.machine.serial
                        xml.manufacturer device.machine.manufacturer
                        xml.model device.machine.model
                      end
                    end
                  end
                end
              end
            end
          end
        end
        #xml << @dp.to_xml(skip_instruct: true, skip_types: true, dasherize: false, root: :digital_provenance, include: [:digital_file_provenances], except: [:created_at, :updated_at, :date, :physical_object_id]).gsub(/^/, '      ').gsub('nil="true"', 'xsi:nil="true"')
      end
    end
  else
    xml.success false
    xml.message @message
  end
end

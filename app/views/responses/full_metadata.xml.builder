xml.instruct! :xml, :version=>"1.0"

xml.pod("xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance") do
  if @success
    xml.success true
    xml.data do
      xml.object do
        xml.basics do
          xml.format @physical_object.format
          xml.files @physical_object.technical_metadatum.master_copies
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
          xml.digitizing_entity @physical_object.digital_provenance.digitizing_entity
          xml.comments @physical_object.digital_provenance.comments
          xml.cleaning_date @physical_object.digital_provenance.cleaning_date
          xml.baking @physical_object.digital_provenance.baking
          xml.repaired @physical_object.digital_provenance.repaired
          xml.cleaning_comment @physical_object.digital_provenance.cleaning_comment
          xml.digitization_time @physical_object.digital_provenance.duration
          xml.digital_files do
            @physical_object.digital_provenance.digital_file_provenances.each do |dfp|
              xml.digital_file_provenance do
                xml.filename dfp.filename
                xml.date_digitized dfp.date_digitized
                xml.comment dfp.comment
                xml.created_by dfp.created_by
                xml.speed_used dfp.speed_used
                xml.signal_chain do
                  dfp.signal_chain.machines.each do |device|
                    xml.device do
                      xml.device_type device.category
                      xml.serial_number device.serial
                      xml.manufacturer device.manufacturer
                      xml.model device.model
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

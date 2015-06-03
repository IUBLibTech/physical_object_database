xml.instruct! :xml, :version=>"1.0"

xml.pod do
   if @success
     xml.success true
     xml.data do
       xml.format @physical_object.format
       xml.files @physical_object.technical_metadatum.master_copies
       xml.details do
         xml.mdpi_barcode @physical_object.mdpi_barcode
         xml.has_ephemera @physical_object.has_ephemera
         xml.ephemera_returned @physical_object.ephemera_returned
         xml.title @physical_object.title
         xml.call_number @physical_object.call_number
         xml.iucat_barcode @physical_object.iucat_barcode
         xml.group_key @physical_object.group_key.group_identifier
         xml.group_position @physical_object.group_position
         xml.carrier_stream_index @physical_object.carrier_stream_index
         xml.workflow_status @physical_object.workflow_status
         xml.author @physical_object.author
         xml.title_control_number @physical_object.title_control_number
         xml.catalog_key @physical_object.catalog_key
         xml.home_location @physical_object.home_location
         xml.oclc_number @physical_object.oclc_number
         xml.other_copies @physical_object.other_copies
         xml.collection_identifier @physical_object.collection_identifier
         xml.collection_name @physical_object.collection_name
         xml.year @physical_object.year
         xml.generation @physical_object.generation
         xml.created_at @physical_object.created_at
         xml.updated_at @physical_object.updated_at
       end
       #FIXME: virtual fields?
       #FIXME: finish TM fields
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
       xml.technical_metadatum do
         xml.preservation_problems @tm.preservation_problems
       end
       xml.digital_provenance do
         xml.digitizing_entity @dp.digitizing_entity
         xml.digitizing_date @dp.date
         xml.comments @dp.comments
         xml.created_by @dp.created_by
	 xml.cleaning do
           xml.date @dp.cleaning_date
           xml.comment @dp.cleaning_comment
	 end
	 xml.player do
           xml.serial_number @dp.player_serial_number
           xml.manufacturer @dp.player_manufacturer
           xml.model @dp.player_model
	 end
	 xml.AD do
	   xml.serial_number @dp.ad_serial_number
	   xml.manufacturer @dp.ad_manufacturer
	   xml.model @dp.ad_model
	 end
	 xml.baking_date @dp.baking
	 xml.repaired @dp.repaired
	 xml.extraction_workstation @dp.extraction_workstation
	 xml.speed_used @dp.speed_used
       end
       if @physical_object.workflow_statuses.any? 
         xml.workflow_statuses do
           @physical_object.workflow_statuses.each_with_index do |ws, i|
	     xml.workflow_status do
	       xml.number i + 1
	       xml.status ws.workflow_status_template.name
	       xml.sequence ws.workflow_status_template.sequence_index
	       xml.has_ephemera ws.has_ephemera
	       xml.ephemera_returned ws.ephemera_returned
	       xml.ephemera_okay ws.ephemera_okay
	       xml.datestamp ws.updated_at
	       xml.user ws.user
	     end
	   end
         end
       else
         xml.workflow_statuses
       end
       if @physical_object.notes.any?
         xml.notes do
           @physical_object.notes.each_with_index do |note, i|
	     xml.note do
	       xml.number i + 1
	       xml.export note.export
	       xml.body note.body
	       xml.user note.user
	       xml.created_at note.created_at
	       xml.updated_at note.updated_at
	     end
	   end
         end
       else
         xml.notes
       end
       if @physical_object.condition_statuses.any?
         xml.condition_statuses do
	   @physical_object.condition_statuses.each_with_index do |cs, i|
	     xml.condition_status do
	       xml.condition cs.condition_status_template.name
	       xml.blocks_packing cs.condition_status_template.blocks_packing
	       xml.active cs.active
	       xml.notes cs.notes
	       xml.user cs.user
	       xml.created_at cs.created_at
	       xml.updated_at cs.updated_at
	     end
	   end
	 end
       else
         xml.condition_statuses
       end
     end
   else
     xml.success false
     xml.message @message
   end
end

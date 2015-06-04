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
       xml.technical_metadata do
         case @physical_object.format
         when "CD-R"
           xml.damage @tm.damage
           xml.preservation_problems do
             xml.breakdown_of_materials @tm.breakdown_of_materials
             xml.fungus @tm.fungus
             xml.other_contaminants @tm.other_contaminants
           end
           xml.format_duration @tm.format_duration
         when "DAT"
           xml.sample_rate do
             xml._32k @tm.sample_rate_32k
             xml._44_1k @tm.sample_rate_44_1_k
             xml._48k @tm.sample_rate_48k
             xml._96k @tm.sample_rate_96k
           end
           xml.format_duration @tm.format_duration
           xml.tape_stock_brand @tm.tape_stock_brand
           xml.preservation_problems do
             xml.fungus @tm.fungus
             xml.soft_binder_syndrome @tm.soft_binder_syndrome
             xml.other_contaminants @tm.other_contaminants
           end
         when "Open Reel Audio Tape"
           xml.pack_deformation @tm.pack_deformation
           xml.preservation_problems do
             xml.vinegar_syndrome @tm.vinegar_syndrome
             xml.fungus @tm.fungus
             xml.soft_binder_syndrome @tm.soft_binder_syndrome
             xml.other_contaminants @tm.other_contaminants
           end
           xml.reel_size @tm.reel_size
           xml.playback_speed do
             xml._0_9375ips @tm.zero_point9375_ips
             xml._1_875ips @tm.one_point875_ips
             xml._3_75ips @tm.three_point75_ips
             xml._7_5ips @tm.seven_point5_ips
             xml._15ips @tm.fifteen_ips
             xml._30ips @tm.thirty_ips
           end
           xml.track_configuration do
             xml.full_track @tm.full_track
             xml.half_track @tm.half_track
             xml.quarter_track @tm.quarter_track
             xml.unknown_track @tm.unknown_track
           end
           xml.tape_thickness do
             xml._0_5mil @tm.zero_point5_mils
             xml._1_0mil @tm.one_mils
             xml._1_5mil @tm.one_point5_mils
           end
           xml.sound_field do
             xml.mono @tm.mono
             xml.stereo @tm.stereo
             xml.unknown_sound_field @tm.unknown_sound_field
           end
           xml.tape_stock_brand @tm.tape_stock_brand
           xml.tape_base do
             xml.acetate_base @tm.acetate_base
             xml.polyester_base @tm.polyester_base
             xml.pvc_base @tm.pvc_base
             xml.paper_base @tm.paper_base
           end
           xml.directions_recorded @tm.directions_recorded
         when "LP"
           xml.diameter @tm.diameter
           xml.speed @tm.speed
           xml.groove_size @tm.groove_orientation
           xml.groove_orientation @tm.groove_orientation
           xml.recording_method @tm.recording_method
           xml.material @tm.material
           xml.sound_field @tm.sound_field
           xml.equalization @tm.equalization
           xml.country_of_origin @tm.country_of_origin
           xml.label @tm.label
           xml.preservation_problems do
             xml.delamination @tm.delamination
             xml.exudation @tm.exudation
             xml.oxidation @tm.oxidation
           end
           xml.damage do
             xml.broken @tm.broken
             xml.cracked @tm.cracked
             xml.dirty @tm.dirty
             xml.fungus @tm.fungus
             xml.scratched @tm.scratched
             xml.warped @tm.warped
             xml.worn @tm.worn
           end
         when "Betacam"
           xml.format_version @tm.format_version
           xml.pack_deformation @tm.pack_deformation
           xml.cassette_size @tm.cassette_size
           xml.recording_standard @tm.recording_standard
           xml.format_duration @tm.format_duration
           xml.tape_stock_brand @tm.tape_stock_brand
           xml.image_format @tm.image_format
         end
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

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
	 xml << @dp.to_xml(skip_instruct: true, skip_types: true, dasherize: false, root: :digital_provenance, include: [:digital_file_provenances], except: [:created_at, :updated_at, :date, :physical_object_id]).gsub(/^/, '      ').gsub('nil="true"', 'xsi:nil="true"')
	 #xml << "      <digital_provenance/>\n"
       end
     end
   else
     xml.success false
     xml.message @message
   end
end

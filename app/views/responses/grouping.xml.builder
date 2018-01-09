xml.instruct! :xml, :version=>"1.0"

xml.pod do
   if @success
     xml.success true
     xml.data do
       xml.group_identifier @physical_object.group_key.group_identifier
       xml.group_total @physical_object.group_key.group_total
       xml.physical_objects_count @physical_object.group_key.physical_objects_count
       xml.physical_objects do
         @physical_object.group_key.physical_objects.order('ABS(group_position)').each do |object|
           xml.physical_object do
             xml.group_position object.group_position
             xml.mdpi_barcode object.mdpi_barcode
           end
         end
       end
     end
   else
     xml.success false
     xml.message @message
   end
end

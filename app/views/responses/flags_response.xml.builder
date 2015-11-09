xml.instruct! :xml, :version=>"1.0"

xml.pod do
   if @success
     xml.success true
   else
     xml.success false
   end
   xml.data do
   	xml.flags @physical_object.digital_provenance.batch_processing_flag
   end
end

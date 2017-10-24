xml.instruct! :xml, :version=>"1.0"

xml.pod do
   if @success
     xml.success true
     xml.data do
       xml.digital_start @physical_object.digital_start
       xml.digital_workflow_status @physical_object.digital_workflow_status
       xml.digital_workflow_category @physical_object.digital_workflow_category&.titleize
     end
   else
     xml.success false
     xml.message @message
   end
end

xml.instruct! :xml, :version=>"1.0"

xml.pod do
   if @success
     xml.success true
     xml.data do
       xml.format @physical_object.format
       xml.files @physical_object.technical_metadatum.master_copies
     end
   else
     xml.success false
     xml.message @message
   end
end

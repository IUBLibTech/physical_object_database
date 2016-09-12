xml.instruct! :xml, :version=>"1.0"

xml.pod do
   if @success
     xml.success true
     xml.data do
       xml.format @physical_object.format
       xml.format_version @physical_object.ensure_tm.format_version if @physical_object.ensure_tm.respond_to? :format_version
       xml.files @physical_object.ensure_tm.master_copies
     end
   else
     xml.success false
     xml.message @message
   end
end

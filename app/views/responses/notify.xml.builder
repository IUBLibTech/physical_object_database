xml.instruct! :xml, :version=>"1.0"

xml.pod do
   if @success
     xml.success true
   else
     xml.success false
   end
    xml.message @message
end

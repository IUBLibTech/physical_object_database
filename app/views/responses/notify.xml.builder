xml.instruct! :xml, :version=>"1.0"

xml.pod do
   if @message.persisted?
     xml.success true
   else
     xml.success false
     if @message.content.blank?
       xml.message "Notification message text must not be blank."
     else
       xml.message "Notification create failed with errors: #{@message.errors.full_messages}"
     end
   end
end

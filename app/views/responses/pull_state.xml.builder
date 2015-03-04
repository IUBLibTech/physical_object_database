xml.instruct! :xml, :version=>"1.0"

xml.pod do
  if @status == 200
    xml.success true
    xml.data do
      xml.state @message
    end
  else
    xml.success false
    xml.message @message
  end
end

xml.instruct! :xml, :version=>"1.0"

xml.pod do
  xml.success (@status == 200)
  xml.message @message
end

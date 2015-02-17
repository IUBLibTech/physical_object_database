json.array!(@messages) do |message|
  json.extract! message, :id, :content
  json.url message_url(message, format: :json)
end

json.array!(@machines) do |machine|
  json.extract! machine, :id, :category, :serial, :manufacturer, :model
  json.url machine_url(machine, format: :json)
end

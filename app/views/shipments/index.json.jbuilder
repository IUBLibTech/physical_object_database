json.array!(@shipments) do |shipment|
  json.extract! shipment, :id, :identifier, :description, :physical_location, :unit_id
  json.url shipment_url(shipment, format: :json)
end

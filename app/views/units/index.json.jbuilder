json.array!(@units) do |unit|
  json.extract! unit, :id, :abbreviation, :name, :institution, :campus
  json.url unit_url(unit, format: :json)
end

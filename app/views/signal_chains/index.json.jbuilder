json.array!(@signal_chains) do |signal_chain|
  json.extract! signal_chain, :id, :name
  json.url signal_chain_url(signal_chain, format: :json)
end

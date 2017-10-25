# Increase key_space_limit to 4x default of 65536, for filmdb XML pushes
if Rack::Utils.respond_to?("key_space_limit=")
  Rack::Utils.key_space_limit = 262144 
end

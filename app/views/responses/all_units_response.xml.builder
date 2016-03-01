xml.pod do
	if @success
		xml.success true
	else
		xml.success false
	end
	xml.message @message
	xml.units do
		@units.each do |u|
			xml.unit do
				xml.abbreviation u.abbreviation
				xml.name u.name
			end
		end
	end
end
xml.pod do
	if @success
		xml.success true
	else
		xml.success false
	end
	xml.message @message
	xml.classes do
		TechnicalMetadatumModule.tm_format_classes.each do |name, klass|
			xml.class do
				xml.type name
				xml.code klass.const_get(:TM_GENRE).to_s.upcase[0]
			end
		end
	end
end

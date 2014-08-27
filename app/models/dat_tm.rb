class DatTm < ActiveRecord::Base
	acts_as :technical_metadatum
	include TechnicalMetadatumModule

	# this hash holds the human reable attribute name for this class
	HUMANIZED_COLUMNS = {
    	:sample_rate_32k => "32k",
    	:sample_rate_44_1_k => "44.1k",
    	:sample_rate_48k => "48k",
    	:sample_rate_96k => "96k"
	}
	
end

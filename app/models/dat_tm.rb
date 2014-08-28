class DatTm < ActiveRecord::Base
	acts_as :technical_metadatum
	include TechnicalMetadatumModule
	extend TechnicalMetadatumClassModule

	# this hash holds the human reable attribute name for this class
	HUMANIZED_COLUMNS = {
    	:sample_rate_32k => "32k",
    	:sample_rate_44_1_k => "44.1k",
    	:sample_rate_48k => "48k",
    	:sample_rate_96k => "96k"
	}
	PRESERVATION_PROBLEM_FIELDS = ["fungus", "soft_binder_syndrome", "other_contaminants"]
	SAMPLE_RATE_FIELDS = ["sample_rate_32k", "sample_rate_44_1_k", "sample_rate_48k", "sample_rate_96k"]

	def sample_rates
		humanize_boolean_fields(*self.class.const_get(:SAMPLE_RATE_FIELDS))
	end

end

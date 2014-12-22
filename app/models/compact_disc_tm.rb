class CompactDiscTm < ActiveRecord::Base
	acts_as :technical_metadatum
	include TechnicalMetadatumModule
	extend TechnicalMetadatumClassModule

	def update_form_params(params)
	end
	#FIXME: deprecate?
end

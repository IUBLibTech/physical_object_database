class CompactDiscTm < ActiveRecord::Base
	acts_as :technical_metadatum
	include TechnicalMetadatumModule

  def update_form_params(params)
	end
end

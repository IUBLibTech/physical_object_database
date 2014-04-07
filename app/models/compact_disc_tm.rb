class CompactDiscTm < ActiveRecord::Base
	acts_as :technical_metadatum

	def generalize
    TechnicalMetadatum.find_by(as_technical_metadatum_id: self.id)
  end

  def update_form_params(params)
	end
end

class LpTm < ActiveRecord::Base
	acts_as :technical_metadatum

	def generalize
    TechnicalMetadatum.find_by(as_technical_metadatum_id: self.id)
  end

  def update_form_params(params)
		puts(params.to_yaml)
    params.require(:lp_tm).permit()
  end

end

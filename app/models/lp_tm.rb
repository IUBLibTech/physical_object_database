class LpTm < ActiveRecord::Base
	acts_as :technical_metadatum
	include TechnicalMetadatumModule
	extend TechnicalMetadatumClassModule

  def update_form_params(params)
    params.require(:lp_tm).permit()
  end
  # FIXME: deprecated?
end

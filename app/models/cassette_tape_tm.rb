class CassetteTapeTm < ActiveRecord::Base
	acts_as :technical_metadatum

	def generalize
    TechnicalMetadatum.find_by(as_technical_metadatum_id: self.id)
  end


end

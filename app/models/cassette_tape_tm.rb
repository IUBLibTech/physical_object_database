class CassetteTapeTm < ActiveRecord::Base
	acts_as :technical_metadatum
	include TechnicalMetadatumModule

end

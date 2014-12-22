class CassetteTapeTm < ActiveRecord::Base
	acts_as :technical_metadatum
	include TechnicalMetadatumModule
	extend TechnicalMetadatumClassModule
	# master_copies ???
end

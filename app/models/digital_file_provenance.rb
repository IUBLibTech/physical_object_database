class DigitalFileProvenance < ActiveRecord::Base
	after_initialize :default_values, if: :new_record?
	belongs_to :digital_provenance
	belongs_to :signal_chain

	attr_accessor :display_date_digitized
	validates :digital_provenance, presence: true
	validates :filename, presence: true, uniqueness: true
	validates :created_by, presence: true
	validates :date_digitized, presence: true
	validates :signal_chain, presence: true

	validates :tape_fluxivity, numericality: {only_integer: true, greater_than: 0, message: "must be an integer value greater than 0."} 
	validates :volume_units, format: {with: /(^[+-]\d+[.\d]*$)|(^0$)/, message: "must be a signed (+/-) decimal value."}
	validates :analog_output_voltage, format: {with: /(^[+-]\d+[.\d]*$)|(^0$)/, message: "must be a signed (+/-) decimal value."}
	validates :peak, numericality: {only_integer: true, less_than: 0, message: "must be an integer value less than 0."} 

	validate :filename_validation



	default_scope { order(:filename) }

        # File Uses:
        # pres for preservation master
        # prod for audio production master
        # mezz for video mezzanine file
        # access for access file
        # pres-int for preservation master-intermediate files
	FILE_USE_VALUES = [ 'pres', 'prod', 'mezz', 'access', 'pres-int']

	def display_date_digitized
		if date_digitized.blank?
			""
		else
			date_digitized.in_time_zone("UTC").strftime("%m/%d/%Y")
		end
	end

	def display_date_digitized=(date)
		unless date.blank?
			self.date_digitized = DateTime.strptime(date, "%m/%d/%Y")
		end
	end

	def default_values
		self.created_by ||= User.current_user
		self.date_digitized ||= Time.now
		self.tape_fluxivity ||= 250
		self.analog_output_voltage ||= "+4"
		self.peak ||= -18
	end

	def filename_validation
	  components = self.filename.to_s.split('_').map { |e| e.split('.') }
	  object = self.digital_provenance && self.digital_provenance.physical_object
	  media_type = object && TechnicalMetadatumModule::TM_GENRES[object.format]
	  media_ext = TechnicalMetadatumModule::GENRE_EXTENSIONS[media_type]
	  if components.size == 4 && components.last.size == 2
	    prefix, barcode, sequence, use, extension = components.flatten
	    errors.add(:filename, "must start with MDPI") unless prefix == "MDPI"
	    errors.add(:filename, "barcode (#{barcode}) match object's barcode (#{self.digital_provenance && self.digital_provenance.physical_object ? self.digital_provenance.physical_object.mdpi_barcode.to_s : ''})") unless self.digital_provenance && self.digital_provenance.physical_object && barcode == self.digital_provenance.physical_object.mdpi_barcode.to_s
	    errors.add(:filename, "must include a valid face number") unless sequence.to_i > 0
	    errors.add(:filename, "must pad face number (#{sequence}) to two digits (01)") if sequence.to_i > 0 && sequence.length != 2
	    errors.add(:filename, "use (#{use}) must be in list of valid uses (#{FILE_USE_VALUES.join(',')})") unless use.in? FILE_USE_VALUES
	    errors.add(:filename, "extension (.#{extension}) must be .#{media_ext} for #{media_type.to_s} files") if object && media_type && extension != media_ext
	  else
	    errors.add(:filename, "must follow pattern: MDPI_(barcode)_(face)_(use).(ext)") unless components.size == 4 && components.last.size == 2
	  end
	end
end

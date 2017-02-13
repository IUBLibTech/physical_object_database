class DigitalFileProvenance < ActiveRecord::Base
	after_initialize :default_values, if: :new_record?
	before_save :nullify_na_values
	belongs_to :digital_provenance
	belongs_to :signal_chain

	attr_accessor :display_date_digitized
	validates :digital_provenance, presence: true
	validates :filename, presence: true, uniqueness: true
	validates :created_by, presence: true
	validates :date_digitized, presence: true
	validates :signal_chain, presence: true, allow_blank: true

	validates :tape_fluxivity, numericality: {only_integer: true, greater_than: 0, message: "must be an integer value greater than 0."}, allow_blank: true
	validates :volume_units, format: {with: /(^[+-]\d+[.\d]*$)|(^0$)/, message: "must be a signed (+/-) decimal value."}, allow_blank: true
	validates :analog_output_voltage, format: {with: /(^[+-]\d+[.\d]*$)|(^0$)/, message: "must be a signed (+/-) decimal value."}, allow_blank: true
	validates :peak, numericality: {only_integer: true, less_than: 0, message: "must be an integer value less than 0."}, allow_blank: true
	validates :rumble_filter, numericality: {only_integer: true, greater_than: 0, message: "must be an integer value greater than 0."}, allow_blank: true
	validates :reference_tone_frequency, numericality: {only_integer: true, greater_than: 0, message: "must be an integer value greater than 0."}, allow_blank: true

	validate :filename_validation
	validate :validate_signal_chain

	default_scope { order(:filename) }

        # File Uses:
        # pres for preservation master
        # prod for audio production master
        # mezz for video mezzanine file
        # access for access file
        # presInt for preservation master-intermediate files
	FILE_USE_HASH = { 'pres' => 'Preservation Master',
		 'prod' => 'Production Master',
		 'mezz' => 'Mezzanine File Version',
		 'access' => 'Access File Version',
		 'presInt' => 'Preservation Master - Intermediate',
		 'presRef' => 'Reference Tone'
		}
	FILE_USE_VALUES = FILE_USE_HASH.keys

	def display_date_digitized
		if date_digitized.blank?
			""
		else
			date_digitized.in_time_zone("UTC").strftime("%m/%d/%Y")
		end
	end

	def display_date_digitized=(date)
		unless date.blank?
			# advance to noon to cover DST shifts
			self.date_digitized = (Time.strptime(date, "%m/%d/%Y") + 12.hours)
		end
	end

	def default_values
		self.created_by ||= User.current_username
		self.date_digitized ||= Time.now
		self.tape_fluxivity ||= 250
		self.analog_output_voltage ||= "+4"
		self.peak ||= -18
		self.volume_units ||= 0
		nullify_na_values
	end

	def nullify_na_values
		if digital_provenance && digital_provenance.physical_object && tm = digital_provenance.physical_object.ensure_tm
			[:tape_fluxivity, :analog_output_voltage, :peak, :volume_units].each do |att|
				self[att]= nil if tm.provenance_requirements[att.to_sym].nil?
			end
		end
	end

	def filename_validation
	  components = self.filename.to_s.split('_').map { |e| e.split('.') }
	  object = self.digital_provenance && self.digital_provenance.physical_object
	  media_type = object && TechnicalMetadatumModule.tm_genres[object.format]
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

  def complete?
    complete = true
    if self.digital_provenance && self.digital_provenance.physical_object && self.digital_provenance.physical_object.ensure_tm
      self.attributes.keys.map { |a| a.to_sym }.select { |a| !a.in? [:id] }.each do |att|
        if self[att].blank? && self.digital_provenance.physical_object.ensure_tm.provenance_requirements[att]
          complete = false
          break
        end
      end
    end
    complete
  end

  def validate_signal_chain
    if signal_chain && digital_provenance && digital_provenance.physical_object
      errors[:signal_chain] << "Physical Object format (#{digital_provenance.physical_object.format}) is not among formats supported by the selected signal chain (#{signal_chain.formats.join(', ')})" unless signal_chain.formats.include? digital_provenance.physical_object.format
    end
  end

  def file_use
    use = ""
    unless self.filename.blank?
      m = self.filename.match /(.*)_(.*?)\.(...)$/
      if m.size >= 3
        use = m[2]
      end
    end
    use
  end

  def full_file_use
    DigitalFileProvenance::FILE_USE_HASH[file_use]
  end

  def file_prefix
    prefix = nil
    unless self.filename.blank?
      m = self.filename.match /(.*)\..*$/
      if m.size >= 1
        prefix = m[1]
      end
    end
    prefix
  end

  def file_ext
    ext = nil
    unless self.filename.blank?
      m = self.filename.match /.*\.(.*)$/
      if m.size >= 2
        ext = m[1]
      end
    end
    ext
  end

  def digital_file_bext
    bext_text = full_file_use
    bext_text += ". " unless bext_text.blank?
    bext_text += file_prefix
    if self.digital_provenance && self.digital_provenance.physical_object
      bext_text = self.digital_provenance.physical_object.file_bext + bext_text
    end
    bext_text
  end

end

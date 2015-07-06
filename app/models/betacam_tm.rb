class BetacamTm < ActiveRecord::Base
	acts_as :technical_metadatum
	include TechnicalMetadatumModule
	extend TechnicalMetadatumClassModule
        include YearModule

	PRESERVATION_PROBLEM_FIELDS = [
	  "fungus", "soft_binder_syndrome", "other_contaminants"
	]
	PACK_DEFORMATION_VALUES = hashify ["", "None", "Minor", "Moderate", "Severe"]
	CASSETTE_SIZE_VALUES = hashify ["", "small", "large"]
	RECORDING_STANDARD_VALUES = hashify ["", "NTSC", "PAL", "SECAM", "Unknown"]
	FORMAT_DURATION_VALUES = hashify ["", 90, 60, 30, 20, 10, 5 ]
	IMAGE_FORMAT_VALUES = hashify ["", "4:3", "16:9", "Unknown"]
	FORMAT_VERSION_VALUES = hashify ["", "Oxide", "SP", "SX", "IMX 30", "IMX 40", "IMX 50", "Digital"]

        SIMPLE_FIELDS = [
          "format_version", "pack_deformation", "cassette_size",
          "recording_standard", "format_duration", "tape_stock_brand",
          "image_format"
        ]
        MULTIVALUED_FIELDSETS = {
          "Preservation problems" => :PRESERVATION_PROBLEM_FIELDS,
        }
        MANIFEST_EXPORT = {
          "Year" => :year,
          "Recording standard" => :recording_standard,
          "Image format" => :image_format,
          "Tape stock brand" => :tape_stock_brand,
          "Size" => :cassette_size,
          "Format duration" => :format_duration,

        }

	validates :pack_deformation, inclusion: { in: PACK_DEFORMATION_VALUES.keys }
	validates :cassette_size, inclusion: { in: CASSETTE_SIZE_VALUES.keys }
	validates :recording_standard, inclusion: { in: RECORDING_STANDARD_VALUES.keys }
	validates :format_duration, inclusion: { in: FORMAT_DURATION_VALUES.keys }
	validates :image_format, inclusion: { in: IMAGE_FORMAT_VALUES.keys }
  validates :format_version, inclusion: { in: FORMAT_VERSION_VALUES.keys }

	def cassette_size_values
		CASSETTE_SIZE_VALUES
	end

	def recording_standard_values
		RECORDING_STANDARD_VALUES
	end

	def format_duration_values
		FORMAT_DURATION_VALUES
	end

	def image_format_values
		IMAGE_FORMAT_VALUES
	end

	def pack_deformation_values
		PACK_DEFORMATION_VALUES
	end

	def format_version_values
		FORMAT_VERSION_VALUES
	end

  def damage
    pack_deformation
  end

end

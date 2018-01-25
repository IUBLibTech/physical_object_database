class DigitalProvenance < ActiveRecord::Base
	belongs_to :physical_object
	has_many :digital_file_provenances
	accepts_nested_attributes_for :digital_file_provenances, allow_destroy: true

	IU_DIGITIZING_ENTITY = "IU Media Digitization Studios"
	MEMNON_DIGITIZING_ENTITY = "Memnon Archiving Services Inc"
	DIGITIZING_ENTITY_VALUES = {
	  IU_DIGITIZING_ENTITY => IU_DIGITIZING_ENTITY,
	  MEMNON_DIGITIZING_ENTITY => MEMNON_DIGITIZING_ENTITY
          }
        CYLINDER_TEXT_COMMENTS = [
          'Undersampled at 48kHz',
          'Overmodulated grooves', 
          'Grooves cut into the edge of cylinder',
          'Captured in reverse',
          'Groove echo',
          'Low level mechanical noise',
          'Irregularly cut grooves',
          'Extremely low level content',
          'No discernible content',
          'Partial transfer',
          'Locked grooves at the end',
          'False start at the beginning'
          ].freeze
        CYLINDER_TIMESTAMP_COMMENTS = [
          :locked_grooves,
          :speed_change,
          :speed_fluctuations,
          :second_attempt
          ].freeze

	validates :physical_object, presence: true

	def digitizing_entity_values
		DIGITIZING_ENTITY_VALUES
	end

  def complete?
    complete = true
    if self.physical_object && self.physical_object.ensure_tm
      self.attributes.keys.map { |a| a.to_sym }.select { |a| !a.in? [:id] }.each do |att|
        if self[att].blank? && self.physical_object.ensure_tm.provenance_requirements[att]
          complete = false
          break
        end
      end
    end
    complete
  end

  def ensure_dfp(options = {})
    if digital_file_provenances.none? && physical_object&.format == 'Cylinder'
      [:pres, :presRef, :presInt, :intRef, :prod].each do |file_use|
        prefix = 'MDPI'
        barcode = physical_object.mdpi_barcode
        sequence = '01' #FIXME: format for integer padding
        extension = (TechnicalMetadatumModule.tm_genres[physical_object.format] == :audio ? 'wav' : 'mkv')
        filename = "MDPI_#{barcode}_#{sequence}_#{file_use}.#{extension}"
        if file_use.to_s.match /Ref/
          reference_tone = 440 if file_use.to_s.match /Ref/
          signal_chain = SignalChain.where(name: 'Cylinder refTone').first
          speed_used = 'N/A'
          stylus_size = 'N/A'
          comment = nil
        else
          reference_tone = nil
          signal_chain = SignalChain.where(name: 'Cylinder audio').first
          speed_used = options['cylinder_dfp_speed_used']
          stylus_size = options['cylinder_dfp_stylus_size']
          if file_use == :prod
            comment = 'De-click, De-crackle, normalized to -7 dBfs. Then Spectral De-noise, EQ, normalized to -7 dBfs again.'
            comment += "\n" if options['cylinder_dfp_comments']&.select(&:present?)&.any? 
          end
          comment ||= ''
          comment += options['cylinder_dfp_comments']&.select(&:present?)&.join("\n").to_s
          timestamp_comments = []
          if file_use == :pres
            CYLINDER_TIMESTAMP_COMMENTS.each do |timestamp_comment|
              timestamps = ''
              if timestamp_comment == :locked_grooves
                timestamps = options["#{timestamp_comment}"] if timestamp_comment == :locked_grooves
              else
                minutes = options["#{timestamp_comment}(4i)"]
                seconds = options["#{timestamp_comment}(5i)"]
                timestamps = "#{minutes.rjust(2,'0')}:#{seconds.rjust(2,'0')}" if minutes.present? || seconds.present?
              end
              if timestamps.present?
                timestamp_comments << "#{timestamp_comment.to_s.humanize} - #{timestamps}"
              end
            end
            if timestamp_comments.any?
              comment += "\n" if comment.present?
              comment += timestamp_comments.join("\n")
            end
          end
        end
        digital_file_provenances.create(filename: filename, reference_tone_frequency: reference_tone, signal_chain: signal_chain, speed_used: speed_used, stylus_size: stylus_size, comment: comment)
      end
    end
  end

end

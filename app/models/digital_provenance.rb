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
    results = []
    if physical_object&.format.in?(TechnicalMetadatumModule.preload_formats) && digital_file_provenances.none?
      preload_values = TechnicalMetadatumModule.tm_format_classes[physical_object.format].const_get(:PRELOAD_CONFIGURATION)
      file_uses = file_uses(preload_values, options)
      (1..preload_values[:sequence]).each do |sequence|
        results += create_dfp_set(options: options, preload_values: preload_values, file_uses: file_uses, sequence: sequence)
      end
    end
    results
  end

  private
    def create_dfp_set(options:, preload_values:, file_uses:, sequence:)
      file_uses.map do |file_use|
        attributes = preload_values[:uses_attributes][file_use].dup
        attributes[:signal_chain] = SignalChain.where(name: attributes[:signal_chain]).first
        preload_values[:form_attributes][file_use].each do |att, form_field|
          attributes[att] = options[form_field.to_s]
        end
        attributes[:filename] = filename(physical_object, sequence, file_use)
        attributes[:comment] = comment_string(attributes[:comment], options, file_use, preload_values, sequence)
        dfp = digital_file_provenances.build(**attributes)
        dfp.save
        dfp
      end
    end

    def file_uses(preload_values, options)
      options['cylinder_dfp_default_uses'] ||= Array.wrap(preload_values.dig(:file_uses, :default))
      options['cylinder_dfp_optional_uses'] ||= []
      default_file_uses = options['cylinder_dfp_default_uses'].select(&:present?).map(&:to_sym)
      optional_file_uses = options['cylinder_dfp_optional_uses'].select(&:present?).map(&:to_sym)
      preload_values[:uses_attributes].keys & (default_file_uses | optional_file_uses)
    end

    def filename(physical_object, sequence, file_use)
      extension = TechnicalMetadatumModule::GENRE_EXTENSIONS[TechnicalMetadatumModule.tm_genres[physical_object.format]]
      "MDPI_#{physical_object.mdpi_barcode}_#{sequence.to_s.rjust(2, '0')}_#{file_use}.#{extension}"
    end

    def comment_string(comment, options, file_use, preload_values, sequence)
      comment ||= ''
      comment = add_text_comment(comment, options, file_use, preload_values, sequence)
      comment = add_timestamp_comment(comment, options, file_use, preload_values, sequence)
    end

    def add_text_comment(comment, options, file_use, preload_values, sequence)
      text_comments = options["cylinder_dfp_comments_#{sequence}"]&.select(&:present?)&.select { |c| file_use.in?(preload_values[:text_comments][c]) }&.join("\n").to_s
      if text_comments.present?
        comment += "\n" if comment.present?
        comment += text_comments
      end
      comment
    end

    def add_timestamp_comment(comment, options, file_use, preload_values, sequence)
      timestamp_comments = []
      preload_values[:timestamp_comments].select { |h,k| file_use.in?(k) }.keys.each do |timestamp_comment|
        timestamps = ''
        # locked_grooves uses raw text entry for timestamps
        if timestamp_comment.in?([:locked_grooves])
          timestamps = options["#{timestamp_comment}_#{sequence}"]
        else
          minutes = options["#{timestamp_comment}_#{sequence}(4i)"]
          seconds = options["#{timestamp_comment}_#{sequence}(5i)"]
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
      comment
    end
end

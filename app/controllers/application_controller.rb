class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper
  # Pundit provides authorization support
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  after_action :verify_authorized, except: [:tm_form]

  # Note that sessions_controller does not inherit from ApplicationController to avoid the following line and the catch-22 result
  before_action :signed_in_user
  around_filter :scope_current_username

  helper_method :tm_partial_path

  def pundit_user
    @pundit_user ||= User.find_by(username: current_username)
  end

  def tm_form
    f = params[:format]
    @edit_mode = params[:edit_mode] == 'true'
    @search_mode = params[:search_mode] == 'true'
    if f.blank?
      @tm = nil
    elsif params[:type] == 'PhysicalObject'
      @physical_object = params[:id] == '0' ? PhysicalObject.new : PhysicalObject.find(params[:id])
      if ! @physical_object.technical_metadatum.nil?
        #this may be an edit cahnging the format
        if f == @physical_object.format
          @tm = @physical_object.technical_metadatum.specific
        else
          @tm = @physical_object.create_tm(f)
        end
      else
        @tm = @physical_object.create_tm(f)
      end
    elsif params[:type] == 'PicklistSpecification'
      @picklist_specification = params[:id] == '0' ? PicklistSpecification.new(format: f) : PicklistSpecification.find(params[:id])
      if !@picklist_specification.technical_metadatum.nil?
        #could be an edit changing the format of the piclist spec
        if f == @picklist_specification.format
          @tm = @picklist_specification.technical_metadatum.specific
        else
          #do not save this - reassigning here so the call to create_tm works
          @picklist_specification.format = f
          @tm = @picklist_specification.create_tm
        end
      else
        @tm = @picklist_specification.create_tm
      end
    end
    if f.blank?
      render(partial: 'technical_metadatum/show_blank_tm')
    elsif @search_mode
      @tm.attributes.keys.each { |att| @tm[att] = nil unless att == "subtype" }
      render(partial: 'technical_metadatum/show_generic_tm')
    else
      render(partial: 'technical_metadatum/' + TechnicalMetadatumModule.tm_partials[f])
    end
  end

  private
    def scope_current_username
      User.current_username = current_username
      yield
    ensure
      User.current_username = nil
    end
  
    #FIXME: redirect to failure page?
    def user_not_authorized
      flash[:warning] = "You are not authorized to perform this action."
      redirect_to(request.referrer || root_path)
    end

    def physical_object_params
      # same as using params[:physical_object] except that it
      # allows listed attributes to be mass-assigned
      # we could also do params.require(:some_field).permit*...
      # if certain fields were required for the object instantiation.
      params.require(:physical_object).permit(:title, :title_control_number,
        :unit_id, :home_location, :call_number, :iucat_barcode, :format,
        :group_key_id, :group_key,
        :group_position, :collection_identifier, :mdpi_barcode, :format_duration,
        :has_ephemera, :ephemera_returned, :author, :catalog_key, :collection_name, :generation, :oclc_number,
        :other_copies, :year, :bin, :bin_id, :unit, :unit_id, :current_workflow_status, :picklist_id,
        :shipment, :shipment_id, :spreadsheet, :spreadsheet_id, :box, :box_id,
        condition_statuses_attributes: [:id, :condition_status_template_id, :notes, :active, :user, :_destroy],
        notes_attributes: [:id, :body, :user, :export, :_destroy],
        # SEARCH multi-select values
        generation: [], workflow_status: []
        # multi-select _id attributes are handled in the search controller
        )
    end
  
    def tm_params
      params.require(:tm).permit(
        # fields that are specific to open reel audio tapes
        :pack_deformation, :reel_size, :track_configuration,
        :tape_thickness, :sound_field, :tape_stock_brand, :tape_base, :directions_recorded,
        :vinegar_syndrome, :fungus, :soft_binder_syndrome, :other_contaminants, :zero_point9375_ips,
        :seven_point5_ips, :one_point875_ips, :fifteen_ips, :three_point75_ips, :thirty_ips, :full_track,
        :half_track, :quarter_track, :unknown_track, :one_mils, :one_point5_mils, :zero_point5_mils,
        :mono, :stereo, :unknown_sound_field, :acetate_base, :polyester_base, :pvc_base, :paper_base,
        :unknown_playback_speed, :dual_mono,
        # fields for cd-r's not covered by open reel audio tape fields
        :damage, :breakdown_of_materials, :format_duration,
        # fields for dat not covered so far
        :sample_rate_32k, :sample_rate_44_1_k, :sample_rate_48k, :sample_rate_96k,
        # fields for analog sound discs
        :diameter, :speed, :groove_size, :groove_orientation, :recording_method, :material, :substrate,
        :coating, :equalization, :country_of_origin, :delamination, :exudation, :oxidation, :cracked,
        :warped, :dirty, :scratched, :worn, :broken, :label,
        :subtype,
        # fields for betacam
        :format_version, :cassette_size, :recording_standard, :image_format,
        # fields for betamax
        :oxide,
        # fields for cylinder
        :groove_pitch, :fragmented, :repaired_break, :damaged_core, :efflorescence,
        # fields for eight mm video
        :playback_speed, :binder_system,
        # fields of half inch open reel video
        :damaged_reel,
        # fields for umatic video
        :size,
        # fields for audiocassette
        :cassette_type, :tape_type, :noise_reduction, :damaged_tape, :damaged_shell,
        :zero_point46875_ips,

        # SEARCH: re-list select attributes with array values, allowing for multi-select
        :pack_deformation => [], :reel_size => [], :track_configuration => [],
        :tape_thickness => [], :sound_field => [], :tape_stock_brand => [], :tape_base => [], :directions_recorded => [],
        :vinegar_syndrome => [], :fungus => [], :soft_binder_syndrome => [], :other_contaminants => [], :zero_point9375_ips => [],
        :seven_point5_ips => [], :one_point875_ips => [], :fifteen_ips => [], :three_point75_ips => [], :thirty_ips => [], :full_track => [],
        :half_track => [], :quarter_track => [], :unknown_track => [], :one_mils => [], :one_point5_mils => [], :zero_point5_mils => [],
        :mono => [], :stereo => [], :unknown_sound_field => [], :acetate_base => [], :polyester_base => [], :pvc_base => [], :paper_base => [],
        :unknown_playback_speed => [],
        # fields for cd-r's not covered by open reel audio tape fields
        :damage => [], :breakdown_of_materials => [], :format_duration => [],
        # fields for dat not covered so far
        :sample_rate_32k => [], :sample_rate_44_1_k => [], :sample_rate_48k => [], :sample_rate_96k => [],   
        # fields for analog sound discs
        :diameter => [], :speed => [], :groove_size => [], :groove_orientation => [], :recording_method => [], :material => [], :substrate => [],
        :coating => [], :equalization => [], :country_of_origin => [], :delamination => [], :exudation => [], :oxidation => [], :cracked => [],
        :warped => [], :dirty => [], :scratched => [], :worn => [], :broken => [], :label => [],
        :subtype => [],
        # fields for betacam
        :format_version => [], :cassette_size => [], :recording_standard => [], :image_format => [],
        # fields for betamax
        :oxide => [],
        # fields for cylinder
        :groove_pitch => [], :fragmented => [], :repaired_break => [], :damaged_core => [], :efflorescence => [],
        # fields for eight mm video
        :playback_speed => [], :binder_system => [],
        # fields for half inch open reel video
        # fields for umatic video
        :size => [],
        # fields for audiocassette
        cassette_type: [], tape_type: [], noise_reduction: []
        )
    end

    def dp_params
      params.require(:digital_provenance).permit(
        :digitizing_entity, :date, :comments, :created_by, :cleaning_date, :cleaning_comment, 
        :baking, :repaired, :duration, :batch_processing_flag, digital_file_provenances_attributes: [
          :id, :filename, :comment, :date_digitized, :display_date_digitized, :created_by,
          :speed_used, :signal_chain_id, :volume_units, :tape_fluxivity, :peak, :analog_output_voltage,
          :stylus_size, :turnover, :rolloff, :noise_reduction, :reference_tone_frequency, 
          :rumble_filter, :_destroy]
      )
    end

    # this method helps determine which view to use to render
    # a partial for a given technical metadatum type. It is assumed
    # that this pass value is the subclass (OpenReelTm, CdrTm, etc)
    # and not the super class TechnicalMetadatum
    def tm_partial_path(technical_metadatum)
      'technical_metadatum/' + TechnicalMetadatumModule.tm_partials[TechnicalMetadatumModule.tm_class_formats[technical_metadatum.class]]
    end
  
end

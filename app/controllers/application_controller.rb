class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper
  # Note that sessions_controller does not inherit from ApplicationController to avoid the following line and the catch-22 result
  before_action :signed_in_user

  helper_method :tm_partial_path

  # this method helps determine which view to use to render
  # a partial for a given technical metadatum type. It is assumed
  # that this pass value is the subclass (OpenReelTm, CassetteTapeTm, etc)
  # and not the super class TechnicalMetadatum
  def tm_partial_path(technical_metadatum)
    puts("Request for TM partial: #{technical_metadatum.class.name}")
  	if technical_metadatum.class.name == "OpenReelTm"
      "technical_metadatum/show_open_reel_tape_tm"
    else
      "technical_metadatum/show_unknown_tm"
    end
  end

  def physical_object_params
    # same as using params[:physical_object] except that it
    # allows listed attributes to be mass-assigned
    # we could also do params.require(:some_field).permit*...
    # if certain fields were required for the object instantiation.
    params.require(:physical_object).permit(:title, :title_control_number, 
      :unit, :home_location, :call_number, :iucat_barcode, :format, 
      :carrier_stream_index, :collection_identifier, :mdpi_barcode, :format_duration,
      :has_media, :author, :catalog_key, :collection_name, :generation, :oclc_number,
      :other_copies, :year, :bin_id, :unit, :current_workflow_status, 
      condition_statuses_attributes: [:id, :condition_status_template_id, :notes, :_destroy])
  end

  def tm_params
    params.require(:tm).permit(:pack_deformation, :reel_size, :track_configuration, 
      :tape_thickness, :sound_field, :tape_stock_brand, :tape_base, :directions_recorded,
      :vinegar_syndrome, :fungus, :soft_binder_syndrome, :other_contaminants, :zero_point9375_ips, 
      :seven_point5_ips, :one_point875_ips, :fifteen_ips, :three_point75_ips, :thirty_ips, :full_track, 
      :half_track, :quarter_track, :unknown_track, :one_mils, :one_point5_mils, :zero_point5_mils, 
      :mono, :stereo, :unknown_sound_field, :acetate_base, :polyester_base, :pvc_base, :paper_base, 
      :unknown_playback_speed, :one_direction, :two_directions, :unknown_direction)
  end

end

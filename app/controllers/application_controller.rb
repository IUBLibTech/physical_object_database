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
  	if technical_metadatum.class == OpenReelTm
      "technical_metadatum/show_open_reel_tape_tm"
    elsif technical_metadatum.class == CdrTm
      "technical_metadatum/show_cdr_tm"
    elsif technical_metadatum.class == DatTm
      "technical_metadatum/show_dat_tm"
    else
      "technical_metadatum/show_unknown_tm"
    end
  end

  def tm_form
    f = params[:format]
    @edit_mode = params[:edit_mode] == 'true'
    if params[:type] == 'PhysicalObject'
      @physical_object = params[:id] == '0' ? PhysicalObject.new : PhysicalObject.find(params[:id])
      if ! @physical_object.technical_metadatum.nil?
        #this may be an edit cahnging the format
        if f == @physical_object.format
          @tm = @physical_object.technical_metadatum.as_technical_metadatum
        else
          @tm = @physical_object.create_tm(f)
        end
      else
        tm = TechnicalMetadatum.new
        @tm = @physical_object.create_tm(f)
        @physical_object.technical_metadatum = tm
        tm.as_technical_metadatum = @tm
      end
    elsif params[:type] == 'PicklistSpecification'
      @picklist_specification = params[:id] == '0' ? PicklistSpecification.new(format: f) : PicklistSpecification.find(params[:id])
      if !@picklist_specification.technical_metadatum.nil?
        #could be an edit changing the format of the piclist spec
        if f == @picklist_specification.format
          @tm = @picklist_specification.technical_metadatum.as_technical_metadatum
        else
          #do not save this - reassigning here so the call to create_tm works
          @picklist_specification.format = f
          @tm = @picklist_specification.create_tm
        end
      else
        @tm = @picklist_specification.create_tm
      end
    end

    if f == "Open Reel Tape"
      render(partial: 'technical_metadatum/show_open_reel_tape_tm')
    elsif f == "CD-R"
      render(partial: 'technical_metadatum/show_cdr_tm')
    elsif f == "DAT"
      render(partial: 'technical_metadatum/show_dat_tm')
    end
  end

  def barcode_assigned(barcode)
    PhysicalObject.where(mdpi_barcode: barcode).size > 0 or 
    Bin.where(mdpi_barcode: barcode).size > 0 or
    Box.where(mdpi_barcode: barcode).size > 0
  end

  def physical_object_params
    # same as using params[:physical_object] except that it
    # allows listed attributes to be mass-assigned
    # we could also do params.require(:some_field).permit*...
    # if certain fields were required for the object instantiation.
    params.require(:physical_object).permit(:title, :title_control_number, 
      :unit, :home_location, :call_number, :iucat_barcode, :format, 
      :carrier_stream_index, :collection_identifier, :mdpi_barcode, :format_duration,
      :has_ephemira, :author, :catalog_key, :collection_name, :generation, :oclc_number,
      :other_copies, :year, :bin_id, :unit, :current_workflow_status, 
      condition_statuses_attributes: [:id, :condition_status_template_id, :notes, :_destroy])
  end

  def tm_params
    params.require(:tm).permit(
      #fields that are specific to open reel tapes
      :pack_deformation, :reel_size, :track_configuration, 
      :tape_thickness, :sound_field, :tape_stock_brand, :tape_base, :directions_recorded,
      :vinegar_syndrome, :fungus, :soft_binder_syndrome, :other_contaminants, :zero_point9375_ips, 
      :seven_point5_ips, :one_point875_ips, :fifteen_ips, :three_point75_ips, :thirty_ips, :full_track, 
      :half_track, :quarter_track, :unknown_track, :one_mils, :one_point5_mils, :zero_point5_mils, 
      :mono, :stereo, :unknown_sound_field, :acetate_base, :polyester_base, :pvc_base, :paper_base, 
      :unknown_playback_speed, :one_direction, :two_directions, :unknown_direction,
      #fields for cd-r's not covered by open reel tape fields
      :damage, :breakdown_of_materials, :format_duration,
      #fields for dat not covered so far
      :sample_rate_32k, :sample_rate_44_1_k, :sample_rate_48k, :sample_rate_96k
      )
  end

end

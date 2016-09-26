class QualityControlController < ApplicationController
  before_action :set_header_title
  before_action :set_memnon_staging, only: [:staging_index]
  before_action :set_iu_staging, only: [:iu_staging_index]

  def index
    if params[:status]
      if DigitalStatus.actionable_status?(params[:status])
        @physical_objects = DigitalStatus.current_actionable_status(params[:status])
      else
        @physical_objects = DigitalStatus.current_statuses(params[:status])
      end
      ActiveRecord::Associations::Preloader.new.preload(@physical_objects, [:unit, :digital_statuses])
    end
  end

  def iu_staging_index
    render 'staging'
  end

  def staging_index
    render 'staging'
  end

  def staging_post
    if params[:selected]
      if params[:commit] and params[:commit] == 'Stage Selected Objects'
        PhysicalObject.where(id: params[:selected].map(&:to_i)).update_all(staging_requested: true, staging_request_timestamp: DateTime.now)
      end
    end
    # this can't be done before the action it's reassigning staged/unstaged objects
    ##set_staging
    # render 'staging'
    redirect_to :back
  end

  def stage
    @success = false
    @msg = ''
    begin
      po = PhysicalObject.find(params[:id])
      po.update_attributes(staging_requested: true, staging_request_timestamp: DateTime.now)
      @success = true
      @msg = "Staging was successfully requested for PhysicalObject #{po.mdpi_barcode}."
    rescue ActiveRecord::RecordNotFound
      @success = false
      @msg = "ERROR: Could not find a record with id: #{params[:id]}."
    end
    render json: [@success, @msg]
  end

  # FIXME: I think this is only being referenced in spec tests now...
  def decide
    @ds = DigitalStatus.find(params[:id])
    @ds.update_attributes(decided: params[:decided], decided_manually: true)
    flash[:notice] = "Updated Digital Status for #{@ds.physical_object.mdpi_barcode} - chose #{@ds.decided}"
    render 'index'
  end

  def direct_qc
    @d_entity = 'Memnon'
    @date = Time.now
    @format_to_physical_objects = {}
    @format = params[:staging] ? params[:staging][:format] : nil
    if @format && @format != 'All'
      @batches = Batch.where(workflow_status: 'Interim Storage', format: @format, destination: @d_entity).order(:identifier)
    else
      @batches = Batch.none
    end
  end

  # displays auto_accept logs
  def auto_accept
  end

  def self.percent(format, entity)
    sp = StagingPercentage.where(format: format).first
    if sp.nil?
      0.0
    else
      entity == 'Memnon' ? sp.memnon_percent / 100.0 : sp.iu_percent / 100.0
    end
  end

  private
  def set_header_title
    @header_title = params[:status].nil? ? '' : params[:status].titleize
    authorize :quality_control
  end

  def set_staging
    # This call is necessary as it initializes any staging percentages for formats
    # that are present in the POD but not present in the staging percentages table.
    StagingPercentagesController::validate_formats
    @date = DateTime.new(Time.now.year, Time.now.month, Time.now.day)
    if params[:staging] && params[:staging][:date] && !params[:staging][:date].blank?
      @date = DateTime.strptime(params[:staging][:date], '%m/%d/%Y')
    end
    @format_to_physical_objects = ActiveSupport::OrderedHash.new
    @formats = []
    if params[:staging] && params[:staging][:format] && params[:staging][:format] != 'All'
      @formats << params[:staging][:format]
    end
  end

  def set_memnon_staging
    set_staging
    @action = 'staging_index'
    @d_entity = 'Memnon'
    @entity = DigitalProvenance::MEMNON_DIGITIZING_ENTITY
    if unit?
      @formats = PhysicalObject.unstaged_formats_by_date_entity_unit(@date, @entity, unit) if @formats.empty?
    else
      @formats = PhysicalObject.unstaged_formats_by_date_entity(@date, @entity) if @formats.empty?
    end
    @formats.each do |format|
      @format_to_physical_objects[format] =
        unit? ?
            PhysicalObject.unstaged_by_date_format_entity_unit(@date, format, @entity, unit) :
            PhysicalObject.unstaged_by_date_format_entity(@date, format, @entity)
    end
  end

  def set_iu_staging
    set_staging
    @action = 'iu_staging_index'
    @d_entity = 'IU'
    @entity = DigitalProvenance::IU_DIGITIZING_ENTITY
    if unit?
      @formats = PhysicalObject.unstaged_formats_by_date_entity_unit(@date, @entity, unit) if @formats.empty?
    else
      @formats = PhysicalObject.unstaged_formats_by_date_entity(@date, @entity) if @formats.empty?
    end
    @formats.each do |format|
      @format_to_physical_objects[format] =
        unit? ?
            PhysicalObject.unstaged_by_date_format_entity_unit(@date, format, @entity, unit) :
            PhysicalObject.unstaged_by_date_format_entity(@date, format, @entity)
    end
  end

  def unit
    params[:staging] and params[:staging][:unit_id] ? params[:staging][:unit_id] : nil
  end
  def unit?
    unit and ! unit.blank?
  end

end

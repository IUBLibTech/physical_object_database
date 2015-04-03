# Does not inherit from ApplicationController to avoid requiring sign-in here
class ResponsesController < ActionController::Base
  require 'nokogiri'
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  include BasicAuthenticationHelper
  before_action :authenticate

  before_action :set_physical_object, only: [:metadata, :pull_state, :push_status]
  before_action :set_request_xml, only: [:notify, :push_status, :transfer_result]

  # GET /responses/objects/:mdpi_barcode/metadata
  def metadata
    if @physical_object
      @status = 200
      @success = true
    end
    render template: 'responses/metadata.xml.builder', layout: false, status: @status
  end

  # POST /responses/notify
  def notify
    @notification = Message.new(content: @request_xml.xpath("/pod/data/message").text)
    if @notification.content.blank?
      @status = 400
      @success = false
      @message = "Notification message text must not be blank."
    elsif @notification.save
      @status = 200
      @success = true
    else
      @status = 500
      @success = false
      @message = "Notification creation failed with errors: #{@message.errors.full_messages}"
    end
    render template: 'responses/notify.xml.builder', layout: false, status: @status
  end

  # POST /responses/objects/<mdpi_barcode>/state
  # QC process action for notifying POD of digital status changes.
  def push_status
    if @physical_object
      ds = DigitalStatus.new.from_xml(@physical_object.mdpi_barcode, @request_xml)
      if ds.valid? && ds.save
        # the digital files for a physical object come in from memnon and Brian's QC will send this message
        # each time they come in from Memnon (they may come in more than once if we reject their files because they
        # faile our QC). Set this timestamp each time this message is sent in
        if ds.state == DigitalStatus::DIGITAL_STATUS_START
          @physical_object.update_attributes(digital_start: ds.updated_at)
        end
        @status = 200
        @success = true
      else
        @status = 400
        @success = false
        @message = "Unable to save digital status, with errors: #{ds.errors.full_messages}"
      end
    end
    render template: 'responses/push_status.xml.builder', layout: false, status: @status
  end

  # GET /responses/objects/:mdpi_barcode/state
  # QC process action to to query the last decision the user made regarding
  # a fork in the qc workflow.
  def pull_state
    if @physical_object
      @status = 200
      @ds = @physical_object.digital_statuses.order("updated_at DESC").last
      unless @ds.nil?
        @success = true
        @message = @ds.decided
      else
        @success = false
        @message = "Physical object #{@physical_object.mdpi_barcode} has 0 Digital Statuses..."
      end
    end
    render template: 'responses/pull_state.xml.builder', layout: false, status: @status
  end

  # NOT IMPLEMENTED YET
  def flags
  end
  def transfer_request
  end
  
  def transfers_index
    @pos = PhysicalObject.where("staging_requested = true AND staged = false")
    @success = true
    render template: 'responses/transfers_index.xml.builder', layout: false, status: 200
  end

  def transfer_result
    po = PhysicalObject.where(mdpi_barcode: params[:mdpi_barcode]).first
    unless po.nil?
      po.update_attributes(staged: true)
      @success = true
    else
      @message = "Could not find physical object with mdpi_barcode: #{params[:mdpi_barcode]}"
    end
    render template: "responses/notify.xml.builder", layout: false, status: 200
  end

  private
    def set_physical_object
      @physical_object = PhysicalObject.find_by(mdpi_barcode: response_params[:mdpi_barcode]) unless response_params[:mdpi_barcode].to_i.zero?
      barcode_not_found if @physical_object.nil?
    end

    def set_request_xml
      @request_xml = Nokogiri::XML(request.body.read)
    end

    def response_params
      params.permit(:mdpi_barcode)
    end

    def barcode_not_found
      @success = false
      if params[:mdpi_barcode].to_i.zero?
        @status = 400
        @message = "MDPI Barcode cannot be 0, blank, or unspecified"
      else
        @status = 200
        @message = "MDPI Barcode #{params[:mdpi_barcode]} does not exist"
      end
    end
end

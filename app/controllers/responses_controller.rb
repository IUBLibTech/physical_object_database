# Does not inherit from ApplicationController to avoid requiring sign-in here
class ResponsesController < ActionController::Base
  require 'nokogiri'
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  include BasicAuthenticationHelper
  include QcXmlModule

  before_action :authenticate

  before_action :set_physical_object, only: [:metadata, :full_metadata, :pull_state, :push_status, :push_memnon_qc]
  before_action :set_request_xml, only: [:notify, :push_status, :transfer_result]

  # GET /responses/objects/:mdpi_barcode/metadata
  def metadata
    if @physical_object
      @status = 200
      @success = true
    end
    render template: 'responses/metadata.xml.builder', layout: false, status: @status
  end

  # GET /responses/objects/:mdpi_barcode/metadata/full
  def full_metadata
    if @physical_object
      @status = 200
      @success = true
    end
    render template: 'responses/full_metadata.xml.builder', layout: false, status: @status
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

  # POST /responses/objects/memnon_qc/:mdpi_barcode
  def push_memnon_qc
    begin
      xml = request.body.read
      # other methods may rely on namespaces so only remove them in a local document
      doc = Nokogiri::XML(xml).remove_namespaces!
      entity = doc.css("IU Carrier Parts DigitizingEntity").first.content
      @po = PhysicalObject.where(mdpi_barcode: params[:mdpi_barcode]).first
      unless entity == "Memnon Archiving Services Inc"
        @success = true
        @message = "Non-memnon xml, ignoring."
      else
        unless @po.nil?
          parse_qc_xml(@po, xml, doc)
          @success = true
          @message = "Saved memnon digiprov xml for physical object: #{@po.mdpi_barcode}" 
        else
          @success = false
          @message = "Could not find physical object: #{params[:mdpi_barcode]}"
        end
      end
    rescue => e
      o = e.message << e.backtrace.join("\n")
      #puts o
      @success = false
      @message = "Something went wrong while parsing DigitizingEntity and/or ManualCheck: \n#{o}"
    end
    render template: "responses/notify.xml.builder", layout: false, status: 200
  end

  # GET /responses/objects/memnon_qc/:mdpi_barcode/
  def pull_memnon_qc
    po = PhysicalObject.where(mdpi_barcode: params[:mdpi_barcode]).first
    msg = po.digital_provenance.nil? ? "No digiprov model" : po.digital_provenance.xml.nil? ? "No xml digiprov" : po.digital_provenance.xml
    render plain: msg, status: 200
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

  # GET /responses/objects/states
  # AQC process to list all barcodes and decisions for objects that are currently in a decision 
  # state WITH a decision - so Brian can query in bulk rather than item by item
  def pull_states
    render template: 'responses/pull_states.xml.builder', layout: false
  end

  def flags
    @physical_object = PhysicalObject.where(mdpi_barcode: params[:mdpi_barcode]).first
    @success = ! @physical_object.nil?
    @message = "<data><flags>foo</flags></data>".html_safe
    render template: "responses/flags_response.xml.builder", layout: false, status: 200
  end

  # NOT IMPLEMENTED YET
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

  def clear
    po = PhysicalObject.where(mdpi_barcode: params[:mdpi_barcode]).first
    unless po.nil? or po.mdpi_barcode < 49000000000000
      po.digital_statuses.delete_all
      @success = true
      @message = "digital statuses for #{params[:mdpi_barcode]} have been deleted"
    else
      @message = "could not find test physical object #{params[:mdpi_barcode]} - or it is not a test record"
    end
    render template: "responses/notify.xml.builder", layout: false, status: 200
  end

  def clear_all
    pos = PhysicalObject.where("mdpi_barcode >= 49000000000000")
    pos.each do |p|
      p.digital_statuses.delete_all
    end
    @success = true
    @message = "deleted digital statuses for #{pos.size} test records"
    render template: "responses/notify.xml.builder", layout: false, status: 200
  end

  def unit_full_name
    unit = Unit.where(abbreviation: params[:abbreviation]).first
    @success = !(unit.nil?)
    @message = unit.nil? ? "Unknown unit abbreviation: #{params[:abbreviation]}" : unit.name
    render template: "responses/notify.xml.builder", layout: false, status: 200
  end

  private
    def set_physical_object
      @physical_object = PhysicalObject.find_by(mdpi_barcode: response_params[:mdpi_barcode]) unless response_params[:mdpi_barcode].to_i.zero?
      if @physical_object.nil?
        barcode_not_found
      else
        @tm = @physical_object.technical_metadatum.specific unless @physical_object.technical_metadatum.nil?
        @dp = @physical_object.ensure_digiprov
      end
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

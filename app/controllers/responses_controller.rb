# Does not inherit from ApplicationController to avoid requiring sign-in here
class ResponsesController < ActionController::Base
  require 'nokogiri'
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  include BasicAuthenticationHelper
  include QcXmlModule

  before_action :authenticate

  before_action :set_physical_object, only: [:metadata, :full_metadata, :digiprov_metadata, :grouping, :pull_state, :push_memnon_qc, :digitizing_entity, :digital_workflow]
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

  # GET /responses/objects/:mdpi_barcode/metadata/digital_provenance
  def digiprov_metadata
    if @physical_object
      if @physical_object.digital_provenance.complete? && @physical_object.digital_provenance.digital_file_provenances.all? { |dfp| dfp.complete? }
        @status = 200
        @success = true
      else
        @status = 200
        @success = false
        @message = "Digital Provenance is missing or incomplete."
      end
    end
    render template: 'responses/digiprov_metadata.xml.builder', layout: false, status: @status
  end

  # GET /responses/objects/:mdpi_barcode/grouping
  def grouping
    if @physical_object
      @status = 200
      @success = true
    end
    render template: 'responses/grouping.xml.builder', layout: false, status: @status
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
    mdpi_barcode = response_params[:mdpi_barcode].to_i
    if mdpi_barcode.zero?
      barcode_not_found
    else
      ds = DigitalStatus.new.from_xml(mdpi_barcode, @request_xml)
      if ds.physical_object.nil?
        barcode_not_found
      elsif ds.save
        # the digital files for a physical object come in from memnon and Brian's QC will send this message
        # each time they come in from Memnon (they may come in more than once if we reject their files because they
        # faile our QC). Set this timestamp each time this message is sent in
        if ds.state == DigitalStatus::DIGITAL_STATUS_START
          ds.physical_object.update_attributes(digital_start: ds.updated_at)
        end
        ds.update_physical_object
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
      if entity == DigitalProvenance::MEMNON_DIGITIZING_ENTITY
        unless @po.nil?
          parse_qc_xml(@po, xml, doc)
          @success = true
          @message = "Saved memnon digiprov xml for physical object: #{@po.mdpi_barcode}"
        else
          @success = false
          @message = "Could not find physical object: #{params[:mdpi_barcode]}"
        end
      elsif entity == DigitalProvenance::IU_DIGITIZING_ENTITY
        unless @po.nil?
          @po.digital_provenance.update_attributes!(digitizing_entity: DigitalProvenance::IU_DIGITIZING_ENTITY)
          @success = true
          @message = "Set digitizing entity for physical object: #{@po.mdpi_barcode}, to #{DigitalProvenance::IU_DIGITIZING_ENTITY}. DigiProv was not parsed."
        else
          @success = false
          @message = "Could not find physical object: #{params[:mdpi_barcode]}"
        end
      else
        @success = false
        @message = "Unknown digitizing entity: #{entity}"
      end
    rescue => e
      o = e.message << e.backtrace.join("\n")
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
    @pos = PhysicalObject.where(staging_requested: true)
    @success = true
    render template: 'responses/transfers_index.xml.builder', layout: false, status: 200
  end

  def transfer_result
    po = PhysicalObject.where(mdpi_barcode: params[:mdpi_barcode]).first
    unless po.nil?
      po.update_attributes(staged: true, staging_requested: false)
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

  def all_units
    @units = Unit.all.order(:abbreviation)
    @success = true
    @message = "returning all units"
    render template: "responses/all_units_response.xml.builder", layout: false, status: 200
  end

  def digitizing_entity
    @success = !@physical_object.nil?
    if @success
      @message = @physical_object.digital_provenance.digitizing_entity.nil? ? "Digitizing entity not set" : @physical_object.digital_provenance.digitizing_entity
    else
      @message = "Unknown physical object: #{params[:mdpi_barcode]}"
    end
    render template: "responses/notify.xml.builder"
  end

  def avalon_url
    gk = GroupKey.where(id: params[:group_key_id]).first
    unless gk.nil?
      if request.post?
        begin
          xml = request.body.read
          doc = Nokogiri::XML(xml).remove_namespaces!
          url = doc.css("pod data avalonUrl").first.content
          gk.update_attributes!(avalon_url: url)
          @success = true
          @message = "Successfully set avalon url for Group Key: #{gk.group_identifier} to: #{gk.avalon_url}"
        rescue => e
          o = e.message << e.backtrace.join("\n")
          @success = false
          @message = "Something went wrong trying to set the avalon url: \n#{o}"
        end
      else
        @success = true
        @message = gk.avalon_url.blank? ? "No url set" : gk.avalon_url
      end
    else
      @success = false
      @message = "Could not find GroupKey with identifier: #{params[:group_key_id]}"
    end
    render template: "responses/notify.xml.builder"
  end

  def processing_classes
    @success = true
    @message = "returning all units"
    render template: "responses/processing_classes_response.xml.builder", layout: false, status: 200
  end

  def push_filmdb_objects
    xml = request.body.read
    @success = true
    @status = 200
    @message = "SUCCESS"

    @results = PhysicalObjectsHelper.parse_xml(xml)
    @failures = @results['failed'] || []
    if @failures.any?
      @message = failures_to_hashes.to_json
      spreadsheet = @results[:spreadsheet]
      if spreadsheet
        spreadsheet.batches.destroy_all
        spreadsheet.bins.destroy_all
        spreadsheet.boxes.destroy_all
        spreadsheet.destroy
      end
      @success = false
    end

    render plain: @message, status: @status
  end

  # GET /responses/objects/:mdpi_barcode/digital_workflow
  def digital_workflow
    if @physical_object
      @status = 200
      @success = true
    end
    render template: 'responses/digital_workflow.xml.builder', layout: false, status: @status
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

    def failures_to_hashes
      @failures.map do |failure|
        { row: failure[0],
          class: failure[1].class.to_s,
          errors: failure[1].errors.full_messages,
          attributes: failure[1].attributes
        }.stringify_keys
      end
    end
end

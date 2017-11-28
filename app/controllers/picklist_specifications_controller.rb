class PicklistSpecificationsController < ApplicationController
  before_action :set_picklist_specification, only: [:show, :edit, :update, :destroy, :query]
  before_action :authorize_collection, only: [:index, :new, :create, :picklist_list, :new_picklist, :query_add]
  before_action :set_picklist_dropdown, only: [:query, :picklist_list]

  def index
    @picklist_specs = PicklistSpecification.all
    @picklists = Picklist.all.order("complete, name")
  end

  def new
    @formats = PhysicalObject.formats
    @edit_mode = true
    @ps = PicklistSpecification.new(id: 0, format: "CD-R")
    @tm = @ps.ensure_tm
    @action = 'create'
    @submit_text = "Create New Picklist Specification"
  end

  def create
    @ps = PicklistSpecification.new(picklist_specification_params)
    @tm = @ps.ensure_tm
    if @ps.save and @tm.update_attributes(tm_params)
      flash[:notice] = "Picklist Specification was successfully created".html_safe
      redirect_to action: :index
    else
      @edit_mode = true
      render :new
    end
  end

  def edit
    @edit_mode = true
    @action = 'update'
    @submit_text = "Update Picklist Specification"
  end

  def update
    PicklistSpecification.transaction do 
      @original_tm = @ps.technical_metadatum
      @ps.assign_attributes(picklist_specification_params)
      tm_assigned = true
      @tm = @ps.ensure_tm
      begin
        @tm.assign_attributes(tm_params)
      rescue
        tm_assigned = false
      end
      if @ps.errors.none? && @ps.valid? && @tm.valid? && tm_assigned
        updated = @ps.save
        @tm.reload
        if @original_tm && @original_tm.specific && (@original_tm.specific.id != @tm.id)
          @original_tm.destroy
        end
      end
      if !tm_assigned
        @ps.errors[:base] << "Technical Metadata format did not match, which was probably the result of a failed format change.  Verify format and technical metadata, then resubmit."
      end
      if updated
        flash[:notice] = "#{@ps.name} successfully updated."
        redirect_to action: :index
      else
        @edit_mode = true
        flash.now[:warning] = "Failed to update #{@ps.name}"
        render action: :edit
      end
    end
  end

  def show
    @edit_mode = false
  end

  def destroy
    if @ps.destroy
      flash[:notice] = "#{@ps.name} was successfully deleted."
    else
      flash[:warning] = "#{@ps.name} could not be deleted."
    end
    redirect_to action: :index
  end

  def query
    po = PhysicalObject.new
    po.attributes.keys.each { |att| po[att] = nil }
    po.format = @ps.format
    if @ps.ensure_tm
      tm_attributes = @ps.ensure_tm.attributes
      tm_attributes.delete_if { |k, v| k.to_sym.in? [:id, :created_at, :updated_at, :picklist_specification_id] }
      tm = po.ensure_tm
      if tm
        tm.attributes.keys.each { |att| tm[att] = nil }
        tm.assign_attributes(tm_attributes)
      end
    end
    @physical_objects = po.physical_object_query(true)
  
    @edit_mode = true
    @action = 'query_add'
    @submit_text = "Add Selected Objects to Picklist"
  end

  def query_add
    if params[:type].nil?
      flash[:notice] = 'No action selected, so no action taken.'
    elsif params[:po_ids].nil? or params[:po_ids].empty?
      flash[:notice] = "No objects selected, so no action taken."
    elsif params[:picklist].nil?
      flash[:warning] = "SYSTEM ERROR: Picklist hash not passed."
    elsif params[:type] == "existing" and params[:picklist][:id].to_i.zero?
      flash[:notice] = "No picklist selected, so no action taken."
    elsif params[:type] == "new" and params[:picklist][:name].blank?
      flash[:notice] = "No name specified for new picklist, so no action taken."
    else
      @picklist = nil
      if params[:type] == "existing"
        @picklist = Picklist.find_by(id: params[:picklist][:id])
	flash[:warning] = "SYSTEM ERROR: Selected picklist not found!" if @picklist.nil?
      elsif params[:type] == "new"
        @picklist = Picklist.new(name: params[:picklist][:name], description: params[:picklist][:description])
        @picklist.save
        flash[:warning] = "Errors creating picklist:<ul>#{@picklist.errors.full_messages.each.inject('') { |output, error| output += ('<li>' + error + '</li>') }}</ul>.".html_safe if @picklist.errors.any?
      end
    end
    
    if flash[:notice].to_s.blank? and flash[:warning].to_s.blank?
      unless params[:po_ids].nil? or @picklist.nil?
	results = { success: 0, failure: 0, errors: [] }
        PhysicalObject.where(id: params[:po_ids]).each do |po|
	  po.picklist_id = @picklist.id
	  if po.save
	    results[:success] += 1
	  else
	    results[:failure] += 1
	    results[:errors] = results[:errors] | po.errors.full_messages
	  end
	end
	flash[:notice] = "#{results[:success]} selected object(s) successfully added to picklist: #{@picklist.name}"
	flash[:warning] = "#{results[:failure]} selected object(s) were NOT added due to errors: #{results[:errors]}"
      end
    end
    redirect_to(action: 'query', id: params[:id])
  end

  def picklist_list
    render(partial: "picklists/picklist_list")
  end

  def new_picklist
    render(partial: "picklists/new_picklist")
  end

  private
    def set_picklist_specification
      @ps = PicklistSpecification.find(params[:id])
      authorize @ps
      @tm = @ps.technical_metadatum
      @tm = @tm.specific unless @tm.nil?
    end

    def authorize_collection
      authorize PicklistSpecification
    end

    def set_picklist_dropdown
      @picklists = Picklist.all.order('name').collect{|p| [p.name, p.id]}
    end

    def picklist_specification_params
      params.require(:ps).permit(:format, :name, :description)
    end

end

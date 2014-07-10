class BatchesController < ApplicationController

  def index
    @batches = Batch.all
  end

  def new

    @batch = Batch.new
  end

  def create
    @batch = Batch.new(batch_params)
    if @batch.save
      flash[:notice] = "<i>#{@batch.name}</i> was successfully created".html_safe
      redirect_to(:action => 'index')
    else 
      render('new')
    end
  end

  def edit
    @batch = Batch.find(params[:id])
  end

  def update
    @batch = Batch.find(params[:id]);
    Batch.transaction do
      if @batch.update_attributes(batch_params)
        flash[:notice] = "<i>#{@batch.name}</i> was successfully updated.".html_safe
        # if a batch status moves forward TO "Shipped", we need to propagate that status to all bins, and then all
        # physical objects in the batch. If the current status ROLLED BACK from "Shipped", we need to also roll back
        # the shipped status on all bins and physical objects
        cs = @batch.current_workflow_status
        ps = @batch.workflow_statuses.size > 1 ? @batch.workflow_statuses[@batch.workflow_statuses.size - 2] : nil
        if (cs.name == "Shipped" or (!ps.nil? and ps.name == "Shipped"))
          csi = cs.workflow_status_template.sequence_index
          psi = ps.workflow_status_template.sequence_index
          # advanced TO shipped
          if (cs.name == "Shipped" and (csi > psi))
            @batch.bins.each do |b|
              b.update_attributes(current_workflow_status: "Shipped")
              b.physical_objects.each do |p|
                p.update_attributes(current_workflow_status: "Shipped")
              end
            end
          # rolled back from shipped
          elsif (ps.name == "Shipped" and (csi < psi)) 
            @batch.bins.each do |b|
              b.update_attributes(current_workflow_status: WorkflowStatusQueryModule.status_name_before(Bin, "Shipped"))
              b.physical_objects.each do |p|
                p.update_attributes(current_workflow_status: WorkflowStatusQueryModule.status_name_before(PhysicalObject, "Shipped"))
              end
            end
          end 
        end

        redirect_to(:action => 'show', :id => @batch.id)
      else
        render('show')
      end
    end
  end

  def show
    if request.format.csv? || request.format.xls?
      params[:id] = params[:id].sub(/batch_/, '')
    end
    @batch = Batch.find(params[:id])
    @available_bins = Bin.available_bins
    @bins = @batch.bins
    respond_to do |format|
      format.html
      format.xls
    end
  end

  def destroy
    @batch = Batch.find(params[:id])
    # Rails does not clear the id field so if a batch is somehow recreated with the same id as the
    # deleted one, all of the previous bins will be incorrectly associated
    Bin.update_all("batch_id = NULL", "batch_id = #{@batch.id}")
    if @batch.destroy
      flash[:notice] = "<i>#{@batch.name}</i> successfully destroyed".html_safe
      redirect_to(:action => 'index')
    else
      flash[:notice] = '<b class="warning">Unable to delete this Batch</b>'.html_safe
      render('show', id: @batch.id)
    end
  end

  def add_bin
    @batch = Batch.find(params[:id])
    Batch.transaction do
      params[:bin_ids].each do |b|
        bin = Bin.find(b)
        stat = WorkflowStatusQueryModule.new_status(bin, "Batched")
        stat.save
        bin.update_attributes(batch_id: @batch.id)
      end
    end
    redirect_to(action: 'show', id: @batch.id)
  end

  def remove_bin
        
  end

  private
    def batch_params
      params.require(:batch).permit(:identifier, :name, :description, :current_workflow_status)
    end
  
  
end

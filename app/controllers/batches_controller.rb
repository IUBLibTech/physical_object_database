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
      flash[:notice] = "<b class='warning'>Warning, {@batch.name} could not be created.</b>".html_safe
      render('new')
    end
  end

  def edit
    @batch = Batch.find(params[:id])
  end

  def update
    @batch = Batch.find(params[:id]);
    if @batch.update_attributes(batch_params)
      flash[:notice] = "<i>#{@batch.name}</i> was successfully updated.".html_safe
      redirect_to(:action => 'show', :id => @batch.id)
    else
      flash[:warning] = "Warning, #{@batch.name} could not be updated.".html_safe
      render('show')
    end
  end

  def show
    if request.format.csv? || request.format.xls?
      params[:id] = params[:id].sub(/batch_/, '')
    end
    @batch = Batch.find(params[:id])
    @bins = @batch.bins
    @physical_objects = PhysicalObject.where(id: -1)
    respond_to do |format|
      format.html
      format.xls
    end
  end

  def delete
    @batch = Batch.find(params[:id])
  end

  def destroy
    @batch = Batch.find(params[:id]).destroy
    flash[:notice] = "<i>#{@batch.name}</i> successfully destroyed".html_safe
    redirect_to(:action => 'index')
  end

  private
    def batch_params
      params.require(:batch).permit(:identifier, :name, :description, :current_workflow_status)
    end
  
  
end

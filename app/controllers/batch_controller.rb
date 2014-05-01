class BatchController < ApplicationController

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
    if @batch.update_attributes(batch_params)
      flash[:notice] = "<i>#{@batch.name}</i> was successfully updated.".html_safe
      redirect_to(:action => 'show', :id => @batch.id)
    else
      render('show')
    end
  end

  def show
    @batch = Batch.find(params[:id])
  end

  def delete
    @batch = Batch.find(params[:id])
  end

  def destroy
    @batch = Batch.find(params[:id])
    if @batch.destroy
      flash[:notice] = "<i>#{@batch.name}</i> successfully destroyed".html_safe
      redirect_to(:action => 'index')
    else
      flash[:notice] = '<b class="warning">Unable to delete this Batch</b>'.html_safe
      render('show', id: @batch.id)
    end
  end

  private
    def batch_params
      params.require(:batch).permit(:identifier, :name, :description, :current_workflow_status)
    end
  
  
end

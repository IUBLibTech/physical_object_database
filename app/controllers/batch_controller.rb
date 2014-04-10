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
      flash[:notice] = "#{@batch.name} was successfully created"
      redirect_to(:action => 'index')
    else 
      flash[:warning] = "#Warning, {@batch.name} could not be created."
      render('new')
    end
  end

  def edit
    @batch = Batch.find(params[:id])
  end

  def update
    @batch = Batch.find(params[:id]);
    if @batch.update_attributes(batch_params)
      flash[:notice] = "#{@batch.name} was successfully updated."
      redirect_to(:action => 'show', :id => @batch.id)
    else
      flash[:warning] = "Warning, #{@batch.name} could not be updated."
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
    @batch = Batch.find(params[:id]).destroy
    flash[:notice] = "#{@batch.name} successfully destroyed"
    redirect_to(:action => 'index')
  end

  private
    def batch_params
      params.require(:batch).permit(:identifier, :name, :description, :batch_status, :current_workflow_status)
    end
  
  
end

class SpreadsheetsController < ApplicationController
  before_action :set_spreadsheet, only: [:show, :edit, :update, :destroy]
  before_action :set_associated_objects, only: [:show]
  before_action :set_modified_objects, only: [:show, :destroy]

  def index
    @spreadsheets = Spreadsheet.all
  end

  def show
    respond_to do |format|
      format.html do
        @physical_objects = @physical_objects.paginate(page: params[:page])
      end
      format.xls do
        @modified_only = (params[:modified] == "true")
        @physical_objects = @modified_objects if @modified_only
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @spreadsheet.update(spreadsheet_params)
        format.html { redirect_to @spreadsheet, notice: 'Spreadsheet was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @spreadsheet.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @modified_objects.empty? || params[:confirmed] == "true"
      @spreadsheet.destroy
      respond_to do |format|
        format.html { redirect_to spreadsheets_url }
        format.json { head :no_content }
      end
    else
      @physical_objects = @modified_objects
      render 'confirm_delete'
    end
  end

  private
    def set_spreadsheet
      #remove spreadsheet_ prefix for CSV/XLS generation
      id = params[:id].to_s.sub(/^spreadsheet_/, '')
      @spreadsheet = Spreadsheet.find(id)
    end

    def set_associated_objects
      @bins = @spreadsheet.bins
      @boxes = @spreadsheet.boxes
      @physical_objects = @spreadsheet.physical_objects
    end

    def set_modified_objects
      @modified_objects = @spreadsheet.physical_objects.where('updated_at > ?', @spreadsheet.created_at)
    end

    def spreadsheet_params
      params.require(:spreadsheet).permit(:filename, :note)
    end
end

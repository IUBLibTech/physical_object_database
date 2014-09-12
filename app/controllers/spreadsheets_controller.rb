class SpreadsheetsController < ApplicationController
  before_action :set_spreadsheet, only: [:show, :edit, :update, :destroy]

  def index
    @spreadsheets = Spreadsheet.all
  end

  def show
  end

  #new disabled

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

  #FIXME: add checks on destroying physical objects, bins, boxes
  def destroy
    @spreadsheet.destroy
    respond_to do |format|
      format.html { redirect_to spreadsheets_url }
      format.json { head :no_content }
    end
  end

  private
    def set_spreadsheet
      @spreadsheet = Spreadsheet.find(params[:id])
      #@physical_objects = @spreadsheet.physical_objects unless @spreadsheet.nil?
    end

    def spreadsheet_params
      params.require(:spreadsheet).permit(:filename, :note)
    end
end

class PodReportsController < ApplicationController
  before_action :set_pod_report, only: [:show, :destroy]
  before_action :authorize_collection, only: [:index, :new, :create]

  # GET /pod_reports
  # GET /pod_reports.json
  def index
    @pod_reports = PodReport.all
  end

  # GET /pod_reports/1
  # GET /pod_reports/1.json
  def show
    respond_to do |format|
      response.headers['Content-Length'] = @pod_report.size.to_s
      format.xls { send_file("public/reports/#{@pod_report.filename}", filename: @pod_report.filename) }
    end
  end

  # included for policy generation
  def create
    redirect_to pod_reports_url
  end

  # DELETE /pod_reports/1
  # DELETE /pod_reports/1.json
  def destroy
    @pod_report.destroy
    respond_to do |format|
      format.html { redirect_to pod_reports_url }
      format.json { head :no_content }
    end
  end

  private
    def set_pod_report
      @pod_report = PodReport.find(params[:id])
      authorize @pod_report
    end

    def pod_report_params
      params.require(:pod_report).permit(:status, :filename)
    end

    def authorize_collection
      authorize PodReport
    end
end

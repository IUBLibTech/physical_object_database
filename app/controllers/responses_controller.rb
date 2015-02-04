class ResponsesController < ApplicationController
  before_action :set_physical_object, only: [:metadata]

  def metadata
    render template: 'responses/metadata.xml.builder', layout: false
  end

  private
    def set_physical_object
      @physical_object = PhysicalObject.find_by(mdpi_barcode: response_params[:barcode]) unless response_params[:barcode].to_i.zero?
    end

    def response_params
      params.permit(:barcode)
    end
end

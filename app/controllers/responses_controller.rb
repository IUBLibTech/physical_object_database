# Does not inherit from ApplicationController to avoid requiring sign-in here
class ResponsesController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper

  before_action :set_physical_object, only: [:metadata]

  def metadata
    render template: 'responses/metadata.xml.builder', layout: false
  end

  # message: handled by messages controller

  private
    def set_physical_object
      @physical_object = PhysicalObject.find_by(mdpi_barcode: response_params[:barcode]) unless response_params[:barcode].to_i.zero?
    end

    def response_params
      params.permit(:barcode)
    end
end

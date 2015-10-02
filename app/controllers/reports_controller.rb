class ReportsController < ApplicationController
  def index
    authorize :report, :index?
  end
end

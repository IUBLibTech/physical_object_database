class WelcomeController < ApplicationController
  def index
    authorize :welcome
  end
end

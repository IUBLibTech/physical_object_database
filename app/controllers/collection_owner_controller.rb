class CollectionOwnerController < ApplicationController
  before_action :check_authorization
  def index
  end
  def show
  end
  def search
  end

  private
    def check_authorization
      authorize :collection_owner
    end
end

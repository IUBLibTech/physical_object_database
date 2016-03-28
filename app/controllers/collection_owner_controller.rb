class CollectionOwnerController < ApplicationController
  before_action :check_authorization

  def index
  end

  def show
    @physical_object = PhysicalObject.find(params[:id])
    unit = Unit.find(pundit_user.unit_id)
    unless unit.id == @physical_object.unit_id
      flash[:warning] = "No Physical object belonging to #{unit.name} with ID: #{params[:id]}"
      redirect_to collection_owner_index_path
    end
  end

  def search
  end

  private
    def check_authorization
      authorize :collection_owner
    end
end

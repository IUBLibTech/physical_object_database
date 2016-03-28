class CollectionOwnerController < ApplicationController
  before_action :check_authorization

  def index
    @physical_objects = PhysicalObject.collection_owner_filter(@pundit_user.unit_id)
    if request.format.html?
      @physical_objects = @physical_objects.paginate(page: params[:page])
    end
  end

  def show
    @physical_object = PhysicalObject.collection_owner_filter(@pundit_user.unit_id).where(id: params[:id]).first
    if @physical_object.nil?
      flash[:warning] = "No Physical object found belonging to #{@pundit_user.unit.name} with ID: #{params[:id]}"
      redirect_to collection_owner_index_path
    end
  end

  def search
  end

  private
    def check_authorization
      authorize :collection_owner
      if @pundit_user.nil? || @pundit_user.unit.nil?
        flash[:warning] = 'You must have an associated Unit to use collection owner services.'
        redirect_to welcome_index_path
      end
    end
end

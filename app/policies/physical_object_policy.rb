class PhysicalObjectPolicy < ApplicationPolicy
  POLICY_CONTROLLER = PhysicalObjectsController
  include PolicyModule
  # grant universal access to #index as it is the landing page
  def index?
    true
  end
end

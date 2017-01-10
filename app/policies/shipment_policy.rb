class ShipmentPolicy < ApplicationPolicy
  POLICY_CONTROLLER = ShipmentsController
  include PolicyModule
end

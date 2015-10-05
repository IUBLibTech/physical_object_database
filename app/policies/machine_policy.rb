class MachinePolicy < ApplicationPolicy
  POLICY_CONTROLLER = MachinesController
  include PolicyModule
end

class UserPolicy < ApplicationPolicy
  POLICY_CONTROLLER = UsersController
  include PolicyModule
end

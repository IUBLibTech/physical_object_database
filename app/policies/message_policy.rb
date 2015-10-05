class MessagePolicy < ApplicationPolicy
  POLICY_CONTROLLER = MessagesController
  include PolicyModule
end

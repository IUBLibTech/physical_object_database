class ReturnPolicy < Struct.new(:user, :return)
  POLICY_CONTROLLER = ReturnsController
  include PolicyModule
  include HeadlessPolicyModule
end

class WelcomePolicy < Struct.new(:user, :welcome)
  POLICY_CONTROLLER = WelcomeController
  include PolicyModule
  include HeadlessPolicyModule
  # grant universal access to #index as it is the landing page
  def index?
    true
  end
end

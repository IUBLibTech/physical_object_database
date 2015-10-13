class StatusTemplatePolicy < Struct.new(:user, :status_template)
  POLICY_CONTROLLER = StatusTemplatesController
  include PolicyModule
  include HeadlessPolicyModule
end

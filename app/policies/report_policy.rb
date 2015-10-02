class ReportPolicy < Struct.new(:user, :report)
  POLICY_CONTROLLER = ReportController
  include PolicyModule
  include HeadlessPolicyModule
end

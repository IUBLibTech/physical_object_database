class ReportPolicy < Struct.new(:user, :report)
  POLICY_CONTROLLER = ReportsController
  include PolicyModule
  include HeadlessPolicyModule
end

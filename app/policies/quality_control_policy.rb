class QualityControlPolicy < Struct.new(:user, :quality_control)
  POLICY_CONTROLLER = QualityControlController
  include PolicyModule
  include HeadlessPolicyModule
end

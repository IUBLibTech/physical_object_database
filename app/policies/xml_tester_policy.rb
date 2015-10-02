class XmlTesterPolicy < Struct.new(:user, :xml_tester)
  POLICY_CONTROLLER = XmlTesterController
  include PolicyModule
  include HeadlessPolicyModule
end

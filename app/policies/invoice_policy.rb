class InvoicePolicy < Struct.new(:user, :invoice)
  POLICY_CONTROLLER = InvoiceController
  include PolicyModule
  include HeadlessPolicyModule
end

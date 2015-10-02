class SpreadsheetPolicy < ApplicationPolicy
  POLICY_CONTROLLER = SpreadsheetsController
  include PolicyModule
end

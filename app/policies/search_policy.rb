class SearchPolicy < Struct.new(:user, :search)
  POLICY_CONTROLLER = SearchController
  include PolicyModule
  include HeadlessPolicyModule
end

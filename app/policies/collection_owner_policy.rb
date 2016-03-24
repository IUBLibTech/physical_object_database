class CollectionOwnerPolicy < Struct.new(:user, :collection_owner)
  POLICY_CONTROLLER = CollectionOwnerController
  include PolicyModule
  include HeadlessPolicyModule
end

# RSpec testing: ???
module HeadlessPolicyModule
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
    raise Pundit::NotAuthorizedError, "must be logged in" unless @user
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
      raise Pundit::NotAuthorizedError, "must be logged in" unless @user
    end

    def resolve
      scope
    end
  end

end

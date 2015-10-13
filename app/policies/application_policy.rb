class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = User.find_by(username: user)
    @record = record
    raise Pundit::NotAuthorizedError, "must be logged in" unless @user
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = User.find_by(username: user)
      @scope = scope
      raise Pundit::NotAuthorizedError, "must be logged in" unless @user
    end

    def resolve
      scope
    end
  end
end

# adds authorization methods for all public instance methods
module PolicyModule
  def self.included(base)
    if base.const_defined?(:POLICY_CONTROLLER) && base.const_get(:POLICY_CONTROLLER).respond_to?(:instance_methods)
      base.const_get(:POLICY_CONTROLLER).instance_methods(false).each do |method|
        base.class_eval do
          define_method(method.to_s + "?") { @user.permit?(base::POLICY_CONTROLLER, method, @record) }
        end
      end
    end 
  end
end

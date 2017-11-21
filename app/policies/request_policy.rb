class RequestPolicy < ApplicationPolicy
  def create?
    user.subscription_active?
  end
end

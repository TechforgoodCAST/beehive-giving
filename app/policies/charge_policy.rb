class ChargePolicy < ApplicationPolicy
  def create?
   !user.subscription_active?
  end

  def thank_you?
    user.subscription_active?
  end
end

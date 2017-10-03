class ChargePolicy < ApplicationPolicy
  def create?
   !user.subscribed?
  end

  def thank_you?
    user.subscribed?
  end
end

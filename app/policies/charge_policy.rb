class ChargePolicy < ApplicationPolicy
  def new?
    !user.subscribed?
  end

  def create?
    !user.subscribed?
  end

  def thank_you?
    user.subscribed?
  end
end

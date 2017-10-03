class EligibilityPolicy < ApplicationPolicy
  def create?
    return true if user.subscribed?
    record.checked_fund? || user.organisation.funds_checked < 3
  end

  def update?
    record.checked_fund?
  end
end

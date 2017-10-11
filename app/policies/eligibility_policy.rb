class EligibilityPolicy < ApplicationPolicy
  def create?
    use_subscription_version(__method__)
  end

  def update?
    use_subscription_version(__method__)
  end

  private

    def v1_create?
      return true if user.subscription_active?
      record.checked_fund? || user.organisation.funds_checked < 3
    end

    def v2_create?
      true
    end

    def v1_update?
      record.checked_fund?
    end

    def v2_update?
      true
    end
end

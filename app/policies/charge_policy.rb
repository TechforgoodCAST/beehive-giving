class ChargePolicy < ApplicationPolicy
  def create?
    record && !record.private?
  end
end

class RevealPolicy < ApplicationPolicy
  def create?
    user.reveals.size < MAX_FREE_LIMIT
  end
end

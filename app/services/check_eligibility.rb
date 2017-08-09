class CheckEligibility < CheckBase
  CHECKS = [Location, OrgType, Quiz, Amount].map(&:new)

  def call_each!(proposal, funds)
    proposal.eligibility.merge! call_each(proposal, funds)
  end

  private

    def preload_associations(funds)
      funds.includes(:districts, :countries, :restrictions)
    end
end

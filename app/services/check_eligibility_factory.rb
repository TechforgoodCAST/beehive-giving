module CheckEligibilityFactory
  def self.new(proposal, funds)
    Check::Each.new(
      [
        Check::Eligibility::Amount.new,
        Check::Eligibility::Location.new,
        Check::Eligibility::OrgIncome.new,
        Check::Eligibility::OrgType.new,
        Check::Eligibility::Quiz.new(proposal, funds)
      ]
    )
  end
end

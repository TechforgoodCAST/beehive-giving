module CheckEligibilityFactory
  def self.new
    Check::Each.new(
      [
        Check::Eligibility::Amount.new,
        Check::Eligibility::Location.new,
        Check::Eligibility::OrgIncome.new,
        Check::Eligibility::OrgType.new,
        Check::Eligibility::Quiz.new
      ]
    )
  end

  def self.stubs # TODO: refactor
    Check::Each.new(
      [
        Check::Eligibility::Location.new
      ]
    )
  end
end

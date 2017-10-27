module CheckSuitabilityFactory
  def self.new
    Check::Each.new(
      [
        Check::Suitability::Amount.new,
        Check::Suitability::Duration.new,
        Check::Suitability::Location.new,
        Check::Suitability::OrgType.new,
        Check::Suitability::Theme.new
      ]
    )
  end
end

class CheckSuitability < CheckBase
  CHECKS = [
    AmountSuitability, DurationSuitability, LocationSuitability,
    OrgTypeSuitability, ThemeSuitability
  ].map(&:new)

  def call_each!(proposal, funds)
    proposal.suitability.merge! call_each(proposal, funds)
  end

  private

    def preload_associations(funds)
      funds.includes(:themes, :districts)
    end

    def key_name(obj)
      obj.class.name.demodulize.underscore.gsub!('_suitability', '')
    end
end
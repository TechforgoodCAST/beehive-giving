class CheckSuitability < CheckBase
  CHECKS = [ThemeSuitability].map(&:new)

  def call_each!(proposal, funds)
    proposal.suitability.merge! call_each(proposal, funds)
  end

  private

    def preload_associations(funds)
      funds.includes(:themes)
    end
end

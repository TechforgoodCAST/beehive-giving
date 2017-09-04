class CheckSuitability < CheckBase
  CHECKS = [
    AmountSuitability, DurationSuitability, LocationSuitability,
    OrgTypeSuitability, ThemeSuitability
  ].map(&:new)

  def call_each!(proposal, funds)
    proposal.suitability = add_total(call_each(proposal, funds))
  end

  private

    def add_total(updates)
      topsis = Topsis.new(updates).rank

      updates.each do |k, _|
        updates[k]['total'] = topsis[k]
      end
    end

    def preload_associations(funds)
      funds.includes(:themes, :districts)
    end

    def key_name(obj)
      obj.class.name.demodulize.underscore.gsub!('_suitability', '')
    end
end

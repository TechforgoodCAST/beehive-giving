class CheckSuitability < CheckBase
  CHECKS = [
    AmountSuitability, DurationSuitability, LocationSuitability,
    OrgTypeSuitability, ThemeSuitability
  ].map(&:new)

  def call_each!(proposal, funds)
    proposal.suitability.merge! add_total(call_each(proposal, funds))
  end

  private

    def add_total(updates)
      updates.each do |k, v|
        updates[k]['total'] = v.all_values_for('score').reduce(&:+)
      end
    end

    def preload_associations(funds)
      funds.includes(:themes, :districts)
    end

    def key_name(obj)
      obj.class.name.demodulize.underscore.gsub!('_suitability', '')
    end
end

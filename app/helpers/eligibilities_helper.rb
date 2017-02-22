module EligibilitiesHelper
  def ensure_restriction_category(category)
    @restrictions.pluck(:category).include?(category)
  end

  def ensure_fund_restriction(e)
    @restrictions.pluck(:id).include?(e.object.restriction_id)
  end

  def render_restriction_details(e)
    @restrictions.pluck(:id, :details).to_h[e.object.restriction_id].capitalize
  end

  def render_restriction_radio_buttons(e)
    Restriction.radio_buttons(
      @restrictions.pluck(:id, :invert).to_h[e.object.restriction_id]
    )
  end
end

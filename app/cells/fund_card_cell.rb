class FundCardCell < Cell::ViewModel
  include RecipientsHelper # TODO: refactor

  def location
    if location_ineligible?
      render locals: { result: link_to('Ineligible', eligibility_proposal_fund_path(model, options[:fund]), class: 'very-poor') }
    else
      render locals: { result: render_recommendation(options[:fund], 'location_score', 2, proposal: model) }
    end
  end

  private

    def location_ineligible?
      model.eligibility[options[:fund]&.slug] &&
        model.eligibility[options[:fund]&.slug]['location'] == false
    end
end

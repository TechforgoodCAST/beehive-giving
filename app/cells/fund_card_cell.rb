class FundCardCell < Cell::ViewModel
  include RecipientsHelper # TODO: refactor

  MESSAGES = {
    'anywhere'  => 'Accepts proposals from <strong>anywhere</strong> in the country.',
    'exact'     => 'Supports <strong>all</strong> of the areas in your proposal.',
    'intersect' => 'Supports <strong>some</strong> of the areas in your proposal.',
    'partial'   => 'Supports <strong>all</strong> of the areas in your proposal.',
    'overlap'   => 'Supports projects in a <strong>smaller</strong> area than you are seeking.',
    'national'  => 'Supports <strong>national</strong> proposals.'
  }.freeze

  SCORES = { 1 => 'Good', 0 => 'Neutral', -1 => 'Poor' }.freeze

  def location
    return unless model.recommendation.key? options[:fund]&.slug
    if location_ineligible?
      render locals: check
    else
      render locals: match
    end
  end

  private

    def location_ineligible?
      model.eligibility[options[:fund]&.slug] &&
        model.eligibility[options[:fund]&.slug]['location'] == false
    end

    def check
      {
        rating: link_to('Ineligible', eligibility_proposal_fund_path(model, options[:fund])),
        message: '<strong>Does not</strong> fund the areas in your proposal.',
        classes: 'very-poor'
      }
    end

    def match
      location = model.recommendation[options[:fund]&.slug]['location']
      {
        rating: SCORES[location['score']],
        message: MESSAGES[location['reason']],
        classes: SCORES[location['score']].downcase
      }
    end
end

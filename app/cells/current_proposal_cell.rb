class CurrentProposalCell < Cell::ViewModel
  include ActionView::Helpers::NumberHelper

  private

    def title
      if model
        model.complete? ? model.title.truncate_words(3) : 'Current proposal'
      else
        'No proposal'
      end
    end

    def total_costs
      number_to_currency(model&.total_costs, unit: '£', precision: 0)
    end

    def funding_type
      { 1 => 'Capital', 2 => 'Revenue' }[model.funding_type]
    end

    def incompelte
      incomplete = { INELIGIBLE => 0, INCOMPLETE => 0, ELIGIBLE => 0 }.merge(
        model.assessments.group(:eligibility_status).size
      )[INCOMPLETE]
      str = pluralize(incomplete, 'fund') + ' unchecked'
      link_to(str, funds_path(model, eligibility: 'to_check'))
    end

    def proposal_summary
      if model
        [total_costs, funding_type, incompelte].compact.join(' • ')
      else
        link_to('Sign in', sign_in_path, class: 'bold') +
          ' or ' +
          link_to('create an account', root_path, class: 'bold') +
          ' to check eligibility & suitability.'
      end
    end
end

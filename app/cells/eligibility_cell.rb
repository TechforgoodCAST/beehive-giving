class EligibilityCell < Cell::ViewModel
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include SimpleForm::ActionViewExtensions::FormHelper

  def card
    render locals: { fund: options[:fund], status: status, criteria: criteria }
  end

  def index
    render locals: { fund: options[:fund], status: status, criteria: criteria }
  end

  def analysis
    render locals: { fund: options[:fund], status: status, criteria: criteria }
  end

  def quiz
    return unless options[:fund].restrictions.exists?
    render locals: { fund: options[:fund] }
  end

  private

    def criteria
      criteria = {
        location:     { title: 'Location' },
        amount:       { title: 'Grant amount' },
        funding_type: { title: 'Funding type' },
        org_type:     { title: 'Organisation type' },
        org_income:   { title: 'Organisation income' }
      }
      if options[:fund].restrictions.exists?
        criteria = { quiz: { title: 'Quiz' } }.merge(criteria)
      end
      criteria_status(criteria)
    end

    def criteria_status(criteria)
      return criteria unless model.present?
      checked = EligibilityContext.new(options[:fund], model).checked_fund?

      criteria.each do |k, v|
        if model.ineligible_reasons(options[:fund].slug).include? k.to_s
          v[:status] = 'ineligible'
          v[:colour] = 'red'
          v[:message] = cell(:eligibility_banner, model, fund: options[:fund], eligible: false).call(k)
          v[:symbol] = 'Ineligible'
        elsif k == :quiz && !checked
          v[:status] = 'to_check'
          v[:colour] = 'blue'
          v[:message] = cell(:quiz, options[:fund], quiz_type: 'Restriction', proposal: model).call(:questions_completed)
          v[:symbol] = 'Incomplete'
        else
          v[:status] = 'eligible'
          v[:colour] = 'green'
          v[:message] = ActionController::Base.helpers.strip_tags(cell(:eligibility_banner, model, fund: options[:fund], eligible: true).call(k))
          v[:symbol] = 'Eligible'
        end
      end
    end

    def status
      return { status: '', colour: '', symbol: '', link_text: '' } unless model.present?
      if model.eligible_status(options[:fund].slug) == 1
        {
          status: 'Eligible',
          colour: 'green',
          symbol: "\u2714".html_safe,
          link_text: 'View full report'
        }
      elsif model.eligible_status(options[:fund].slug).zero?
        {
          status: 'Ineligible',
          colour: 'red',
          symbol: "\u2718".html_safe,
          link_text: 'Find out why'
        }
      else
        {
          status: 'Incomplete',
          colour: 'blue',
          symbol: '<span class="white dot dot-14 bg-blue mr3"></span>'.html_safe,
          message: cell(:quiz, options[:fund], quiz_type: 'Restriction', proposal: model).call(:questions_completed),
          link_text: 'Complete this check'
        }
      end
    end

    def protect_against_forgery?
      controller.send(:protect_against_forgery?)
    end

    def form_authenticity_token(*args)
      controller.send(:form_authenticity_token, *args)
    end
end

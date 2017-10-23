class EligibilityCell < Cell::ViewModel
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include SimpleForm::ActionViewExtensions::FormHelper

  def page
    return unless options[:fund].restrictions.present?
    render locals: { fund: options[:fund], status: status, criteria: criteria }
  end

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
    return unless options[:fund].restrictions.present?
    render locals: { fund: options[:fund] }
  end

  private

    def criteria
        criteria = {
            location: {title: 'Location'},
            amount: {title: 'Grant amount'},
            org_type: {title: 'Organisation type'},
            org_income: {title: 'Organisation income'}
        }
        if options[:fund].restrictions.present?
            criteria[:quiz] = {title: 'Additional question'.pluralize(options[:fund].restrictions.size)}
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
          v[:symbol] = "\u2718".html_safe
        elsif k == :quiz && !checked
          v[:status] = 'to_check'
          v[:colour] = 'blue'
          v[:message] = cell(:quiz, options[:fund], quiz_type: 'Restriction', proposal: model).call(:questions_completed)
          v[:message] << "<br><a href=\"#eligibility-quiz\" class=\"blue\">Complete the quiz below</a>".html_safe
          v[:symbol] = '<span class="white dot dot-14 bg-blue mr3"></span>'.html_safe
        else
          v[:status] = 'eligible'
          v[:colour] = 'green'
          v[:message] = ActionController::Base.helpers.strip_tags(cell(:eligibility_banner, model, fund: options[:fund], eligible: true).call(k))
          v[:symbol] = "\u2714".html_safe
        end
      end
    end

    def status
        return { status: "", colour: "", symbol: "", link_text: ""} unless model.present?
        if model.eligible_status(options[:fund].slug) == 1
            {
                status: "Eligible",
                colour: "green",
                symbol: "\u2714".html_safe,
                link_text: "View full report"
            }
        elsif model.eligible_status(options[:fund].slug) == 0
            {
                status: "Ineligible",
                colour: "red",
                symbol: "\u2718".html_safe,
                link_text: "Find out why"
            }
        else
            {
                status: "Incomplete",
                colour: "blue",
                symbol: "<span class=\"white dot dot-14 bg-blue mr3\"></span>".html_safe,
                message: cell(:quiz, options[:fund], quiz_type: 'Restriction', proposal: model).call(:questions_completed),
                link_text: "Complete this check"
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

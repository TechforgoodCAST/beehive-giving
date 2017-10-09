class EligibilityCell < Cell::ViewModel
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include SimpleForm::ActionViewExtensions::FormHelper

  def page
    render locals: { fund: options[:fund], status: status, criteria: criteria }
  end

  def card
    render locals: { fund: options[:fund], status: status, criteria: criteria }
  end

  def index
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
            criteria[:quiz] = {title: 'Additional questions'}
        end
        criteria_status(criteria)
    end

    def criteria_status(criteria)
        criteria.each do |k, v|
            if model.ineligible_reasons(options[:fund].slug).include? k.to_s
                criteria[k][:status] = 'ineligible'
                criteria[k][:colour] = 'red'
                criteria[k][:message] = cell(:eligibility_banner, model, fund: options[:fund]).call(k)
                criteria[k][:symbol] = "\u2718".html_safe
            elsif k == :quiz && !model.checked_fund?(options[:fund])
                criteria[k][:status] = 'to_check'
                criteria[k][:colour] = 'blue'
                criteria[k][:message] = cell(:quiz, options[:fund], quiz_type: 'Restriction', proposal: model).call(:questions_completed)
                criteria[k][:message] << "\nComplete the quiz below"
                criteria[k][:symbol] = "<span class=\"white dot dot-14 bg-blue mr3\"></span>".html_safe
            else
                criteria[k][:status] = 'eligible'
                criteria[k][:colour] = 'green'
                criteria[k][:symbol] = "\u2714".html_safe
            end
        end
    end

    def status
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
end

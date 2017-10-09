class SuitabilityCell < Cell::ViewModel
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
    return unless options[:fund].priorities.present?
    render locals: { fund: options[:fund] }
  end

  private

    def criteria
        criteria = {
            location: {title: 'Location'},
            amount: {title: 'Grant amount'},
            org_type: {title: 'Organisation type'},
            duration: {title: 'Funding duration'},
            theme: {title: 'Funding themes'},
        }
        if options[:fund].priorities.present?
            criteria[:quiz] = {title: 'Additional questions'}
        end
        criteria_status(criteria)
    end

    def criteria_status(criteria)
        criteria.each do |k, v|
            score = model.suitability[options[:fund].slug]&.dig(k.to_s, "score") || 0
            status = score_to_status(score)
            v[:colour] = status[:colour]
            v[:symbol] = status[:symbol]
            v[:status] = status[:title]
            v[:message] = status[:title]
        end
    end

    def score_to_status(score, scale = 1)
        scale = score > 1 ? score.ceil : 1
        [
            {score: 0, title: 'Unavailable', colour: 'blue', symbol: "<span class=\"white dot dot-14 bg-blue mr3\"></span>".html_safe},
            {score: 0.2, title: 'Very poor', colour: 'red', symbol: "\u2718".html_safe},
            {score: 0.4, title: 'Poor', colour: 'red', symbol: "\u2718".html_safe},
            {score: 0.6, title: 'Fair', colour: 'blue', symbol: "~"},
            {score: 0.8, title: 'Good', colour: 'green', symbol: "\u2714".html_safe},
            {score: 1.0, title: 'Excellent', colour: 'green', symbol: "\u2714".html_safe},
        ].each do |v|
            return v if score <= (v[:score] * scale)
        end
    end

    def status
        score = model.suitability[options[:fund].slug]&.dig("total") || 0
        status = score_to_status(score)
        {
            status: (score < 0.5 ? "Unsuitable" : "Suitable"),
            colour: status[:colour],
            symbol: status[:symbol],
            link_text: "Find out more" 
        }
    end
    
    def protect_against_forgery?
        controller.send(:protect_against_forgery?)
    end

    def form_authenticity_token(*args)
        controller.send(:form_authenticity_token, *args)
    end
end

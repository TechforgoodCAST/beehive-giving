class SuitabilityCell < Cell::ViewModel
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include SimpleForm::ActionViewExtensions::FormHelper
  include ActionView::Helpers::NumberHelper

  LOCATION_MESSAGES = {
    'anywhere'  => 'Accepts proposals from <strong>anywhere</strong> in the country.',
    'exact'     => 'Supports <strong>all</strong> of the areas in your proposal.',
    'intersect' => 'Supports <strong>some</strong> of the areas in your proposal.',
    'partial'   => 'Supports <strong>all</strong> of the areas in your proposal.',
    'overlap'   => 'Supports projects in a <strong>smaller</strong> area than you are seeking.',
    'national'  => 'Supports <strong>national</strong> proposals.'
  }.freeze

  def page
    return unless options[:fund].priorities.present?
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
            score = model.suitability[options[:fund].slug]&.dig(k.to_s, "score")
            reason = model.suitability[options[:fund].slug]&.dig(k.to_s, "reason")
            status = score_to_status(score)
            v[:colour] = status[:colour]
            v[:symbol] = status[:symbol]
            v[:status] = status[:title]
            v[:message] = message(k, score, reason)
        end
    end

    def score_to_status(score, scale = 1)
        return {
            score: nil, 
            title: 'Unavailable', 
            colour: 'blue', 
            symbol: "<span class=\"white dot dot-14 bg-blue mr3\"></span>".html_safe
        } if score == nil
        scale = score > 1 ? score.ceil : 1
        [
            {score: 0.2, title: 'Unsuitable', colour: 'red', symbol: "\u2718".html_safe},
            {score: 0.5, title: 'Suitability', colour: 'yellow', symbol: "~"},
            {score: 1.0, title: 'Suitable', colour: 'green', symbol: "\u2714".html_safe},
        ].each do |v|
            return v if score <= (v[:score] * scale)
        end
    end

    def status
        score = model.suitability[options[:fund].slug]&.dig("total")
        status = score_to_status(score)
        status[:link_text] = "Find out more"
        status[:status] = status[:title]
        status
    end

    def message(criteria, score, reason)
        case criteria
        when :amount
            return "No grants for a similar amount." if score == 0
            "#{number_to_percentage(score * 100, precision: 0)} of grants were for a similar amount."
        when :location
            LOCATION_MESSAGES[reason]
        when :org_type
            org_type = ORG_TYPES[model.recipient.org_type + 1][2]
            return "No grants to #{org_type}." if score == 0
            "#{number_to_percentage(score * 100, precision: 0)} of grants were to #{org_type}."
        when :duration
            return "No grants for a similar length." if score == 0
            "#{number_to_percentage(score * 100, precision: 0)} of grants were for a similar length."
        when :theme
            themes = model.themes.map{ |t| t.name } & options[:fund].themes.map{ |t| t.name }
            return "No themes in common with your proposal" if themes.size == 0
            "This fund works in #{themes.take(3).to_sentence}."
        when :quiz
            "#{number_to_percentage(score * 100, precision: 0)} of grants were for a similar amount."
        end
    end
    
    def protect_against_forgery?
        controller.send(:protect_against_forgery?)
    end

    def form_authenticity_token(*args)
        controller.send(:form_authenticity_token, *args)
    end
end

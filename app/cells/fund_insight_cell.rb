class FundInsightCell < Cell::ViewModel
  include ActionView::Helpers::NumberHelper
  include FundsHelper

  property :name
  property :funder

  def grant_examples
    return unless model.open_data? && model.grant_examples?
    grants = []
    model.grant_examples[0..2].each do |g|
      grants << {
        id: g.fetch("id", nil),
        recipient: g.fetch("recipient", "(recipient not known)"),
        amount: g.fetch("amount", nil) ? number_to_currency(g.fetch("amount", 0), precision: 0, unit: "£") : nil,
        url: g.fetch("id", nil) ? "http://grantnav.threesixtygiving.org/grant/#{g.fetch("id", "")}" : nil,
        award_date: g.fetch("award_date", nil) ? g.fetch("award_date", nil)&.to_date&.strftime("%B %Y") : nil,
        title: g.fetch("title", "")
      }
    end
    if model.grant_examples.length > 1
      render locals: {message: "Recent grants include:", grant_examples: grants}
    else
      render locals: {message: "Example of a recent grant:", grant_examples: grants}
    end
  end

  def title
    render locals: { proposal: options[:proposal] }
  end

  def themes
    model.themes.map do |theme|
      link_to(
        theme.name,
        theme_path(theme),
        class: 'blue nowrap'
      )
    end.join('<span class="mid-gray"> &middot; </span>')
  end

  def summary
    messages = []
    
    # get location
    messages << model.geo_description_html

    # messages << (model.national? ? "National" : "Local")

    # get grant types
    costs = model.permitted_costs
                 .select{ |c| c!= 0 }
                 .map{ |c| FUNDING_TYPES[c][0].split.first.downcase }
                 .to_sentence(two_words_connector: " & ", last_word_connector: " & ")
    if costs.present?
      messages << "#{costs.capitalize} grants"
    end

    # get amount
    if model.min_amount_awarded_limited || model.max_amount_awarded_limited
      opts = {precision: 0, unit: "£"}
      messages << if !model.min_amount_awarded_limited || model.min_amount_awarded == 0
        "#{number_to_currency(1, opts)} - #{number_to_currency(model.max_amount_awarded, opts)}"
      elsif !model.max_amount_awarded_limited
        "#{number_to_currency(model.min_amount_awarded, opts)} +"
      else
        "#{number_to_currency(model.min_amount_awarded, opts)} - #{number_to_currency(model.max_amount_awarded, opts)}"
      end
    end

    messages.join('<span class="mid-gray"> &middot; </span>')
  end

  def duration
    return unless model.min_duration_awarded_limited || model.max_duration_awarded_limited
    if !model.min_duration_awarded_limited || model.min_duration_awarded == 0
      render locals: {message: "up to #{months_to_str(model.max_duration_awarded)}"}
    elsif !model.max_duration_awarded_limited
      render locals: {message: "more than #{months_to_str(model.min_duration_awarded)}"}
    else
      render locals: {message: "between #{months_to_str(model.min_duration_awarded)} and #{months_to_str(model.max_duration_awarded)}"}
    end
  end

  def amount
    return unless model.min_amount_awarded_limited || model.max_amount_awarded_limited
    opts = {precision: 0, unit: "£"}
    if !model.min_amount_awarded_limited || model.min_amount_awarded == 0
      render locals: {message: "up to #{number_to_currency(model.max_amount_awarded, opts)}"}
    elsif !model.max_amount_awarded_limited
      render locals: {message: "more than #{number_to_currency(model.min_amount_awarded, opts)}"}
    else
      render locals: {message: "between #{number_to_currency(model.min_amount_awarded, opts)} and #{number_to_currency(model.max_amount_awarded, opts)}"}
    end
  end

  def grant_count
    return unless model.open_data? && model.grant_count?
    render locals: {grant_count: model.grant_count}
  end

  def award_months
    return unless model.open_data? && model.award_month_distribution?
    render locals: {message: top_award_months(model)}
  end

  def countries
    return unless model.open_data && model.country_distribution?
    render locals: {message: top_countries(model)}
  end

  def data_source
    return unless model.sources.present?
    render locals: { proposal: options[:proposal] }
  end

  private

    def title_name
      funder.funds.size > 1 ? [name, funder.name] : [funder.name, name]
    end

    def months_to_str(months)
      if months == 12
        '1 year'
      elsif months < 24
        "#{months} months"
      elsif (months % 12).zero?
        "#{months / 12} years"
      else
        "#{months_to_str(months - (months % 12))} and #{months % 12} months"
      end
    end

    def theme_path(theme)
      if options[:proposal]
        theme_proposal_funds_path(options[:proposal], theme)
      else
        public_funds_theme_path(theme)
      end
    end
end

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
        id: g.fetch('id', nil),
        recipient: g.fetch('recipient', '(recipient not known)'),
        amount: g.fetch('amount', nil) ? number_to_currency(g.fetch('amount', 0), precision: 0, unit: '£') : nil,
        url: g.fetch('id', nil) ? "http://grantnav.threesixtygiving.org/grant/#{g.fetch('id', '')}" : nil,
        award_date: g.fetch('award_date', nil) ? g.fetch('award_date', nil)&.to_date&.strftime("%B %Y") : nil,
        title: g.fetch('title', '')
      }
    end
    if model.grant_examples.length > 1
      render locals: { message: 'Recent grants include:', grant_examples: grants }
    else
      render locals: { message: 'Example of a recent grant:', grant_examples: grants }
    end
  end

  def title
    render locals: { proposal: options[:proposal] }
  end

  def themes
    model.themes.map do |theme|
      link_to(
        theme.name,
        theme_path(theme, options[:proposal]),
        class: "tag #{theme.classes}"
      )
    end.join('<span class="night"> • </span>')
  end

  def summary
    [
      model.geo_area.short_name,
      grant_types_message,
      model.amount_desc.try(:capitalize)
    ].compact.join(' • ')
  end

  def duration
    return unless model.min_duration_awarded_limited || model.max_duration_awarded_limited
    render locals: { message: model.duration_desc }
  end

  def costs
    costs = model.permitted_costs
                 .reject(&:zero?)
                 .map { |c| FUNDING_TYPES[c][0].split.first.downcase }
                 .to_sentence(two_words_connector: ' & ', last_word_connector: ' & ')
    return unless costs.present?
    render locals: { message: costs }
  end

  def amount
    return unless model.min_amount_awarded_limited || model.max_amount_awarded_limited
    render locals: { message: model.amount_desc }
  end

  def grant_count
    return unless model.open_data? && model.grant_count?
    render locals: { grant_count: model.grant_count }
  end

  def award_months
    return unless model.open_data? && model.award_month_distribution?
    render locals: { message: top_award_months(model) }
  end

  def countries
    return render locals: { message: model.geo_area.short_name } if model.geo_area.short_name
    return unless model.open_data && model.country_distribution?
    render locals: { message: top_countries(model) }
  end

  def data_source
    return unless model.sources.present?
    render locals: { proposal: options[:proposal] }
  end

  private

    def title_name
      funder.funds.size > 1 ? [name, funder.name] : [funder.name, name]
    end

    def grant_types_message
      costs = model.permitted_costs.reject(&:zero?)
                   .map { |c| FUNDING_TYPES[c][0].split.first.downcase }
                   .to_sentence(
                     two_words_connector: ' & ', last_word_connector: ' & '
                   )
      "#{costs.capitalize} grants" if costs.present?
    end
end

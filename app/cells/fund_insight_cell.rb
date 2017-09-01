class FundInsightCell < Cell::ViewModel
  include ActionView::Helpers::NumberHelper

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

  property :name
  property :funder

  def title
    render locals: { proposal: options[:proposal] }
  end

  def themes
    render locals: {proposal: options[:proposal], themes: model.themes.order(:name)}
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
        return "1 year"
      elsif months < 24
        return "#{months} months"
      elsif months % 12 == 0
        return "#{months / 12} years"
      else
        return "#{months_to_str(months - (months % 12))} and #{months % 12} months"
      end
    end
end

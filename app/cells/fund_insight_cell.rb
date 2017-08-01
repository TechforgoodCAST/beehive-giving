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

  def title_raw
    title_name[0]
  end

  private

    def title_name
      funder.funds.size > 1 ? [name, funder.name] : [funder.name, name]
    end
end

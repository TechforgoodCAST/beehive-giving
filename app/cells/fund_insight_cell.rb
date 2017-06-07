class FundInsightCell < Cell::ViewModel
  property :name
  property :funder

  def title
    render locals: { proposal: options[:proposal] }
  end

  private

    def title_name
      funder.funds.size > 1 ? [name, funder.name] : [funder.name, name]
    end
end

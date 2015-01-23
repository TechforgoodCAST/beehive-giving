child(@recipient => :timeline) do
  attributes name: :headline, country: :text

  node :type do
    "default"
  end

  node :date do
    @grants.map { |g| Hash[[
      [:startDate, g.start_on.strftime("%y,%m,%d")],
      [:endDate, g.end_on.strftime("%y,%m,%d")],
      [:headline, number_to_currency(g.amount_awarded.to_s, unit: '£', precision: 0)],
      [:text, g.grant_type],
      [:tag, g.funder.name]
    ]] }
  end
end

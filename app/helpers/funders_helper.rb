module FundersHelper

  def percentage_of_grants(funder)
    if @funders.to_a.count == Funder.all.count
      val = 0
    else
      val = @funders.to_a.count
    end

    if funder.grants.count == 0
      '0%'
    else
      number_to_percentage((val.to_f / funder.grants.count.to_f) * 100, precision: 0)
    end
  end

end

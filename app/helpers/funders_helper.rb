module FundersHelper

  def percentage_of_grants(funder)
    if @funders.where('name = ?', funder.name).to_a.count == 1
      val = 0
    else
      val = @funders.where('name = ?', funder.name).to_a.count
    end

    if funder.grants.count == 0
      '0%'
    else
      number_to_percentage((val.to_f / funder.grants.count.to_f) * 100, precision: 0)
    end
  end

end

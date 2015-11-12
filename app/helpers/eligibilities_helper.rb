module EligibilitiesHelper
  def get_restriction_details(id)
    Restriction.find(id).details.slice(0,1).capitalize + Restriction.find(id).details.slice(1..-1)
  end
end

class FundContext < ApplicationContext
  def self.policy_class
    FundPolicy
  end

  def featured
    fund.featured
  end
end

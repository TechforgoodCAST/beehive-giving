class FundContext < ApplicationContext
  def self.policy_class
    FundPolicy
  end

  def slug
    fund.slug
  end
end

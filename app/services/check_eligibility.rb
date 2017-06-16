class CheckEligibility
  def initialize(checks = {})
    raise 'Invalid hash of checks' unless checks.is_a? Hash
    @checks = checks
  end

  def check_all(funds, eligibility = {})
    updates = eligibility.clone
    funds.each do |fund|
      @checks.each do |theme, obj|
        updates[fund.slug] = {} unless updates.key? fund.slug
        updates[fund.slug][theme] = obj.check(fund)
        updates[fund.slug].compact!
      end
    end
    updates
  end
end

class CheckEligibility
  CHECKS = [Location, OrgType, Quiz].map(&:new)

  def call_each(proposal, funds)
    validate_call_each(proposal, funds)
    updates = proposal.eligibility.clone
    preload(funds).each do |fund|
      CHECKS.each do |check|
        updates[fund.slug] = {} unless updates.key? fund.slug
        updates[fund.slug][key_name(check)] = check.call(proposal, fund)
        updates[fund.slug].compact!
      end
    end
    updates
  end

  private

    def validate_call_each(proposal, funds)
      raise 'Invalid Proposal' unless proposal.is_a? Proposal
      raise 'Invalid Fund::ActiveRecord_Relation' unless
        funds.is_a? Fund::ActiveRecord_Relation
    end

    def preload(funds)
      funds.includes(:districts, :countries, :restrictions)
    end

    def key_name(obj)
      obj.class.name.demodulize.underscore
    end

    def call(proposal, fund)
      raise 'Invalid Proposal' unless proposal.is_a? Proposal
      raise 'Invalid Fund' unless fund.is_a? Fund
    end
end

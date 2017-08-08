class CheckBase
  CHECKS = []

  def call_each(proposal, funds)
    validate_call_each(proposal, funds)
    updates = {}
    remove_funds_not_passed_in!(funds, updates)
    preload_associations(funds).each do |fund|
      self.class::CHECKS.each do |check|
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
        funds.class.to_s == 'Fund::ActiveRecord_Relation'
    end

    def remove_funds_not_passed_in!(funds, updates)
      (updates.keys - funds.pluck('slug')).each do |inactive|
        updates.delete inactive
      end
    end

    def preload_associations(funds)
      funds
    end

    def key_name(obj)
      obj.class.name.demodulize.underscore
    end

    def call(proposal, fund)
      raise 'Invalid Proposal' unless proposal.is_a? Proposal
      raise 'Invalid Fund' unless fund.is_a? Fund
    end
end
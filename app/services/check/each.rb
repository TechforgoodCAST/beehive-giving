module Check
  class Each
    def initialize(criteria)
      raise 'Must supply Array of checks' unless criteria.is_a? Array
      @criteria = criteria
    end

    def call_each(proposal, funds)
      validate_call_each(proposal, funds)
      updates = {}
      remove_funds_not_passed_in!(funds, updates)
      preload_associations(funds).each do |fund|
        @criteria.each do |check|
          updates[fund.slug] = {} unless updates.key? fund.slug
          updates[fund.slug][key_name(check)] = check.call(proposal, fund)
          updates[fund.slug].compact!
        end
      end
      updates
    end

    def call_each_with_total(proposal, funds) # TODO: refactor
      updates = call_each(proposal, funds)
      return {} if updates.empty?
      topsis = Topsis.new(updates).rank

      updates.each do |k, _|
        updates[k]['total'] = topsis[k]
      end
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

      def preload_associations(funds) # TODO: refactor
        funds.includes(:countries, :districts, :themes)
      end

      def key_name(obj)
        obj.class.name.demodulize.underscore
      end
  end
end

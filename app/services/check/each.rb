module Check
  class Each
    def initialize(criteria)
      raise ArgumentError, 'Must supply Array of checks' unless
        criteria.is_a?(Array)
      @criteria = criteria
    end

    def call_each(funds, proposal)
      fund_version = Fund.version
      updates = []

      assessments = persisted_assessments(funds, proposal)
      proposal    = preload_proposal(proposal)
      recipient   = preload_recipient(proposal)

      preload_funds(funds).each do |fund|
        assessment = assessments[fund.id] || build(fund, proposal, recipient)
        @criteria.each { |check| check.new.call(assessment) }
        assessment.fund_version = fund_version
        updates << assessment if assessment.valid?
      end

      updates.select(&:changed?)
    end

    private

      def persisted_assessments(funds, proposal) # TODO: avoid duplicate call
        Assessment.includes(
          fund: %i[geo_area countries districts restrictions],
          proposal: %i[answers countries districts],
          recipient: %i[answers]
        ).where(fund: funds.pluck(:id), proposal: proposal)
         .map { |a| [a.fund_id, a] }.to_h
      end

      def preload_recipient(proposal)
        Recipient.includes(:answers).find(proposal.recipient_id)
      end

      def preload_proposal(proposal)
        Proposal.includes(:answers, :countries, :districts).find(proposal.id)
      end

      def preload_funds(funds)
        funds.includes(:geo_area, :countries, :districts, :restrictions)
      end

      def build(fund, proposal, recipient)
        Assessment.new(fund: fund, proposal: proposal, recipient: recipient)
      end

      def validate_call_each(proposal, funds) # TODO: deprecated
        raise 'Invalid Proposal' unless proposal.is_a? Proposal
        raise 'Invalid collection of Funds' unless
          funds.respond_to?(:each) && funds.try(:klass) == Fund
      end

      def remove_funds_not_passed_in!(funds, updates) # TODO: deprecated
        (updates.keys - funds.pluck('slug')).each do |inactive|
          updates.delete inactive
        end
      end

      def preload_associations(funds) # TODO: deprecated
        funds.includes(:countries, :districts, :themes)
      end

      def key_name(obj) # TODO: deprecated
        obj.class.name.demodulize.underscore
      end
  end
end

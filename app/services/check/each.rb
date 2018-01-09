module Check
  class Each
    def initialize(criteria)
      raise ArgumentError, 'Must supply Array of checks' unless
        criteria.is_a?(Array)
      @criteria = criteria
    end

    def call_each(funds, proposal)
      updates = []

      assessments = persisted_assessments(funds, proposal)
      proposal    = preload_proposal(proposal)
      recipient   = preload_recipient(proposal)

      preload_funds(funds).each do |fund|
        assessment = assessments[fund.id] || build(fund, proposal, recipient)
        @criteria.each { |check| check.call(assessment) }
        updates << assessment
      end

      updates.select(&:changed?)
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

      def persisted_assessments(funds, proposal)
        Assessment.includes(:fund, :proposal, :recipient)
                  .where(fund: funds, proposal: proposal)
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
  end
end

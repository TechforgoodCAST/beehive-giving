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
        @criteria.each { |check| check.new.call(assessment) }
        updates << assessment if assessment.valid?
      end

      updates.select(&:changed?)
    end

    private

      def build(fund, proposal, recipient)
        Assessment.new(fund: fund, proposal: proposal, recipient: recipient)
      end

      def persisted_assessments(funds, proposal) # TODO: avoid duplicate call
        Assessment.includes(
          fund: %i[geo_area countries districts restrictions],
          proposal: %i[answers countries districts],
          recipient: %i[answers]
        ).where(fund: funds.pluck(:id), proposal: proposal)
         .map { |a| [a.fund_id, a] }.to_h
      end

      def preload_funds(funds)
        funds.includes(:geo_area, :countries, :districts, :restrictions)
      end

      def preload_proposal(proposal)
        Proposal.includes(:answers, :countries, :districts).find(proposal.id)
      end

      def preload_recipient(proposal)
        Recipient.includes(:answers).find(proposal.recipient_id)
      end
  end
end

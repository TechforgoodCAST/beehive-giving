module RevealsTracker
  include Mixpanelable

  private

    def mixpanel_params(proposal_id)
      revealed = reveals_summary(proposal_id)

      %w[Incomplete Ineligible Eligible].map do |state|
        const = state.upcase.constantize
        {
          "#{state} Reveals Count" => revealed[const].try(:size),
          "#{state} Revealed" => revealed[const].to_json
        }
      end.reduce({}, :merge)
    end

    def mixpanel_track(user, request, opts = {})
      MIXPANEL.track(user.id, "Revealed #{opts[:fund_slug]}")
      mixpanel_identify(user, request, mixpanel_params(opts[:proposal_id]))
    end

    def reveals_summary(id)
      Assessment.joins(:fund)
                .where(proposal_id: id, revealed: true)
                .group(:eligibility_status)
                .select(:eligibility_status, 'array_agg(funds.name) AS names')
                .map { |a| [a.eligibility_status, a.names] }
                .to_h
    end
end

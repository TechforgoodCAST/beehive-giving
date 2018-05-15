ActiveAdmin.register Assessment do
  ratings = {
    UNASSESSED => 'unassessed',
    ELIGIBLE   => 'eligible',
    INCOMPLETE => 'incomplete',
    INELIGIBLE => 'ineligible'
  }

  index do
    column :id
    column :fund
    column :proposal_id
    actions
  end

  filter :fund_id
  filter :proposal_id
  filter :eligibility_status

  show do
    attributes_table title: 'Fund' do
      row(:funder) { |a| a.fund.funder.name }
      row(:fund) { |a| a.fund.name }
    end

    attributes_table title: 'Proposal' do
      # Request
      row(:title) { |a| a.proposal.title }
      row(:description) { |a| a.proposal.tagline }
      row :themes do |a|
        a.proposal.themes.pluck(:name).join(" \&bull; ").html_safe
      end
      row 'How much funding is sought?' do |a|
        number_to_currency(a.proposal.total_costs, unit: '£', precision: 0)
      end
      row 'Is this all of the funding required for the proposed work?' do |a|
        a.proposal.all_funding_required
      end
      row 'How many months is funding required for?' do |a|
        "#{a.proposal.funding_duration} months"
      end
      row 'What type of grant funding is sought?' do |a|
        FUNDING_TYPES[a.proposal.funding_type][0].truncate_words(2, omission: '')
      end

      # Recipient
      row 'Who will be receiving the funding?' do |a|
        ORG_TYPES[a.recipient.org_type + 1][0]
      end

      # Location
      row 'Where will proposed work affect?' do |a|
        Proposal::AFFECT_GEO[a.proposal.affect_geo][0]
      end
      row 'Which countries will proposed work affect?' do |a|
        a.proposal.countries.pluck(:name).join(" \&bull; ").html_safe
      end
      row 'Which areas will proposed work affect?' do |a|
        a.proposal.districts.pluck(:name).join(" \&bull; ").html_safe
      end
    end

    attributes_table title: 'Eligibility' do
      row(:rating) { |a| h3(ratings[a.eligibility_status]) }

      opts = { assessment: assessment }
      [
        Rating::Eligibility::Amount.new(opts),
        Rating::Eligibility::FundingType.new(opts),
        Rating::Eligibility::OrgIncome.new(opts),
        Rating::Eligibility::Location.new(opts),
        Rating::Eligibility::Quiz.new(opts),
        Rating::Eligibility::OrgType.new(opts)
      ].each do |r|
        row(r.title) do
          div("[#{r.status}] #{r.message}".html_safe, contenteditable: true)
        end
      end
    end

    attributes_table title: 'Suitability' do
      row(:rating) { h3(contenteditable: true) }
      %i[
        activities
        amount
        duration
        funding_type
        location
        org_income
        org_type
        priorities
      ].each do |r|
        row(r) { div(contenteditable: true) }
      end
    end
  end

  csv do
    column(:id)
    column(:created_at)
    column(:updated_at)

    column(:recipient) { |a| a.recipient.name }
    column(:charity_number) { |a| a.recipient.charity_number }
    column(:company_number) { |a| a.recipient.company_number }

    column(:proposal_amount) { |a| a.proposal.total_costs }

    column(:eligibility_status) { |a| ratings[a.eligibility_status] }
    column(:eligibility_amount) { |a| ratings[a.eligibility_amount] }
    column(:eligibility_funding_type) { |a| ratings[a.eligibility_funding_type] }
    column(:eligibility_location) { |a| ratings[a.eligibility_location] }
    column(:eligibility_org_income) { |a| ratings[a.eligibility_org_income] }
    column(:eligibility_org_type) { |a| ratings[a.eligibility_org_type] }
    column(:eligibility_quiz) { |a| ratings[a.eligibility_quiz] }

    column(:themes_matched_count) { |a| (a.proposal.themes.pluck(:slug) & a.fund.themes.pluck(:slug)).size }

    column(:sub_country) { |a| a.proposal.districts.pluck(:sub_country).uniq.compact }
    column(:regions) { |a| a.proposal.districts.pluck(:region).uniq.compact }
  end
end

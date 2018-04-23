ActiveAdmin.register Assessment do
  index do
    column :id
    column :fund
    actions
  end

  filter :fund, input_html: { class: 'choices-select' }

  ratings = {
    UNASSESSED => 'unassessed',
    ELIGIBLE   => 'eligible',
    INCOMPLETE => 'incomplete',
    INELIGIBLE => 'ineligible'
  }

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

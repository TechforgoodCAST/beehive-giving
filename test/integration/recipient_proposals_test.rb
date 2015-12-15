require 'test_helper'

class RecipientProposalsTest < ActionDispatch::IntegrationTest

  setup do
    @recipient = create(:recipient)
    create(:profile, organisation: @recipient)
    setup_funders(3)
  end

  test 'add proposal cta visible if no proposal' do
    visit recommended_funders_path
    assert page.has_content? 'Did you know?', count: 1
    click_link 'Improve my funding'
    assert_equal new_recipient_proposal_path(@recipient), current_path

    visit all_funders_path
    assert page.has_content? 'Did you know?', count: 1
    click_link 'Improve my funding'
    assert_equal new_recipient_proposal_path(@recipient), current_path
  end

  test 'cta hidden if one proposal exisits' do
    create(:proposal, recipient: @recipient)

    visit recommended_funders_path
    assert_not page.has_content? 'Did you know?', count: 1

    visit all_funders_path
    assert_not page.has_content? 'Did you know?', count: 1
  end

  def complete_form
    fill_in 'proposal_title', with: @proposal.title
    fill_in 'proposal_tagline', with: @proposal.tagline
    check("proposal_beneficiary_ids_#{@proposal.beneficiaries[0].id}")
    select(Profile::GENDERS.sample, from: 'proposal_gender')
    fill_in 'proposal_min_age', with: @proposal.min_age
    fill_in 'proposal_max_age', with: @proposal.max_age
    fill_in 'proposal_beneficiaries_count', with: @proposal.beneficiaries_count
    select('United Kingdom', from: 'proposal_country_ids', match: :first)
    select('Other', from: 'proposal_district_ids', match: :first)
    fill_in 'proposal_funding_duration', with: @proposal.funding_duration
    fill_in 'proposal_activity_costs', with: @proposal.activity_costs
    fill_in 'proposal_people_costs', with: @proposal.people_costs
    fill_in 'proposal_capital_costs', with: @proposal.capital_costs
    fill_in 'proposal_other_costs', with: @proposal.other_costs
    choose 'Yes'
    fill_in 'proposal_outcome1', with: @proposal.outcome1
  end

  test 'can create a proposal' do
    @proposal = build(:proposal, recipient: @recipient)

    visit new_recipient_proposal_path(@recipient)
    within('#new_proposal') do
      complete_form
    end
    click_button 'Improve my results'

    assert_equal recommended_funders_path, current_path
    assert page.has_content? 'Recommendations for'
  end

  test 'adding proposal updates recommendations' do
    @funders[0].grants.each { |g| g.update_column(:amount_awarded, 1000) }
    @funders[1].grants.each { |g| g.update_column(:amount_awarded, 1000) }

    create(:proposal, recipient: @recipient, activity_costs: 2500, people_costs: 2500, capital_costs: 2500, other_costs: 2500)
    assert_equal 1, @recipient.load_recommendation(@funders.last).grant_amount_recommendation
    visit recommended_funders_path
    Capybara.match = :first
    click_link('More info')
    assert_equal funder_path(@funders.last), current_path
  end

  test 'funder insights reflect proposal comparison' do
    visit recommended_funders_path

    assert page.has_content? "amount you're seeking", count: 1
    assert page.has_content? "duration you're seeking", count: 1

    Grant.all.each { |g| g.update_column(:days_from_start_to_end, 365) }
    proposal = create(:proposal, recipient: @recipient, activity_costs: 2500, people_costs: 2500, capital_costs: 2500, other_costs: 2500)
    visit recommended_funders_path

    assert page.has_content? "amount you're seeking", count: 3
    assert page.has_content? "duration you're seeking", count: 3

    Grant.all.each { |g| g.update_column(:days_from_start_to_end, nil) }
    proposal.save
    visit recommended_funders_path

    assert page.has_content? "amount you're seeking", count: 3
    assert_not page.has_content? "duration you're seeking"
  end

  test 'edit proposal visible if more than one proposal exisits' do
    visit recipient_proposals_path(@recipient)
    assert_equal recommended_funders_path, current_path

    create(:proposal, recipient: @recipient)
    visit recommended_funders_path
    assert page.has_content? 'Funding proposals', count: 2
    Capybara.match = :first
    click_link 'Funding proposals'
    assert_equal recipient_proposals_path(@recipient), current_path
  end

  test 'can update funding proposal' do
    @proposal = create(:proposal, recipient: @recipient)

    visit edit_recipient_proposal_path(@recipient, @proposal)
    within("#edit_proposal_#{@proposal.id}") do
      complete_form
    end
    click_button 'Improve my results'

    assert_equal recipient_proposals_path(@recipient), current_path
  end

  test 'must add proposal to apply to funder' do
    @proposal = build(:proposal, recipient: @recipient)
    assert_equal 0, @recipient.proposals.count
    @recipient.set_eligibility(@funders.first, 'Eligible')
    visit recipient_apply_path(@funders.first)
    assert_equal new_recipient_proposal_path(@recipient), current_path

    within('#new_proposal') do
      complete_form
    end
    click_button 'Improve my results'
    assert_equal recipient_apply_path(@funders.first), current_path
  end

  test 'can only create one funding proposal' do
    create(:proposal, recipient: @recipient)
    visit new_recipient_proposal_path(@recipient)
    assert_equal recipient_proposals_path(@recipient), current_path
  end

end

require 'test_helper'

class RecipientProposalsTest < ActionDispatch::IntegrationTest

  setup do
    @recipient = create(:recipient)
    setup_funders(3)
  end

  test 'improve proposal cta visible if proposal state initial' do
    skip
    create(:initial_proposal, recipient: @recipient)
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
    skip
    create(:initial_proposal, recipient: @recipient)

    visit recommended_funders_path
    assert_not page.has_content? 'Did you know?', count: 1

    visit all_funders_path
    assert_not page.has_content? 'Did you know?', count: 1
  end

  test 'redirect to edit incomplete first proposal if not complete' do
    skip
    registered_proposal = create(:registered_proposal, recipient: @recipient)
    visit new_recipient_proposal_path(@recipient)
    assert_equal edit_recipient_proposal_path(@recipient, registered_proposal), current_path
  end

  def check_path(path)
    visit path
    assert_equal new_recipient_proposal_path(@recipient), current_path
  end

  test 'redirect to new proposal if no proposal found' do
    skip
    check_path(recommended_funders_path)
    check_path(all_funders_path)
    check_path(eligible_funders_path)
    check_path(ineligible_funders_path)
    check_path(edit_recipient_proposal_path(@recipient))
    check_path(recipient_proposals_path(@recipient))
  end

  def initial_complete_form
    select(Proposal::TYPE_OF_SUPPORT.sample, from: 'proposal_type_of_support')
    fill_in 'proposal_funding_duration', with: @initial_proposal.funding_duration
    select(Proposal::FUNDING_TYPE.sample, from: 'proposal_funding_type')
    fill_in 'proposal_total_costs', with: @initial_proposal.total_costs
    choose 'proposal_all_funding_required_true'

    choose('proposal_affect_people_true')
    select(Proposal::GENDERS.sample, from: 'proposal_gender')
    check("proposal_beneficiary_ids_#{Beneficiary.first.id}")
    check("proposal_age_group_ids_#{AgeGroup.first.id}")
    choose('proposal_affect_other_false')

    choose('An entire country')
    select(Country.first.name, from: 'proposal_country_ids', match: :first) # javascript
  end

  test 'can create inital proposal' do
    @initial_proposal = build(:initial_proposal, recipient: @recipient)

    visit new_recipient_proposal_path(@recipient)
    within('#new_proposal') do
      initial_complete_form
    end
    click_button 'Next'

    assert_equal recommended_funders_path, current_path
    assert page.has_content? 'Recommended funders'
  end

  # test 'adding proposal updates recommendations' do
  #   @funders[0].grants.each { |g| g.update_column(:amount_awarded, 1000) }
  #   @funders[1].grants.each { |g| g.update_column(:amount_awarded, 1000) }
  #
  #   create(:initial_proposal, recipient: @recipient, activity_costs: 2500, people_costs: 2500, capital_costs: 2500, other_costs: 2500)
  #   assert_equal 1, @recipient.load_recommendation(@funders.last).grant_amount_recommendation
  #   visit recommended_funders_path
  #   Capybara.match = :first
  #   click_link('More info')
  #   assert_equal funder_path(@funders.last), current_path
  # end
  #
  # test 'funder insights reflect proposal comparison' do
  #   visit recommended_funders_path
  #
  #   assert page.has_content? "amount you're seeking", count: 1
  #   assert page.has_content? "duration you're seeking", count: 1
  #
  #   Grant.all.each { |g| g.update_column(:days_from_start_to_end, 365) }
  #   proposal = create(:initial_proposal, recipient: @recipient, activity_costs: 2500, people_costs: 2500, capital_costs: 2500, other_costs: 2500)
  #   visit recommended_funders_path
  #
  #   assert page.has_content? "amount you're seeking", count: 3
  #   assert page.has_content? "duration you're seeking", count: 3
  #
  #   Grant.all.each { |g| g.update_column(:days_from_start_to_end, nil) }
  #   proposal.save
  #   visit recommended_funders_path
  #
  #   assert page.has_content? "amount you're seeking", count: 3
  #   assert_not page.has_content? "duration you're seeking"
  # end
  #
  # test 'edit proposal visible if more than one proposal exisits' do
  #   visit recipient_proposals_path(@recipient)
  #   assert_equal recommended_funders_path, current_path
  #
  #   create(:initial_proposal, recipient: @recipient)
  #   visit recommended_funders_path
  #   assert page.has_content? 'Funding proposals', count: 2
  #   Capybara.match = :first
  #   click_link 'Funding proposals'
  #   assert_equal recipient_proposals_path(@recipient), current_path
  # end
  #
  # test 'can update funding proposal' do
  #   @proposal = create(:initial_proposal, recipient: @recipient)
  #
  #   visit edit_recipient_proposal_path(@recipient, @proposal)
  #   within("#edit_proposal_#{@proposal.id}") do
  #     initial_complete_form
  #   end
  #   click_button 'Improve my results'
  #
  #   assert_equal recipient_proposals_path(@recipient), current_path
  # end
  #
  # test 'must add proposal to apply to funder' do
  #   @proposal = build(:initial_proposal, recipient: @recipient)
  #   assert_equal 0, @recipient.proposals.count
  #   @recipient.set_eligibility(@funders.first, 'Eligible')
  #   visit recipient_apply_path(@funders.first)
  #   assert_equal new_recipient_proposal_path(@recipient), current_path
  #
  #   within('#new_proposal') do
  #     initial_complete_form
  #   end
  #   click_button 'Improve my results'
  #   assert_equal recipient_apply_path(@funders.first), current_path
  # end
  #
  # test 'can only create one funding proposal' do
  #   create(:initial_proposal, recipient: @recipient)
  #   visit new_recipient_proposal_path(@recipient)
  #   assert_equal recipient_proposals_path(@recipient), current_path
  # end

end

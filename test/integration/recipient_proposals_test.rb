require 'test_helper'

class RecipientProposalsTest < ActionDispatch::IntegrationTest

  # TODO:  refactor tests

  setup do
    @recipient = create(:recipient)
    setup_funders(3)
  end

  def check_path(path)
    visit path
    assert_equal new_recipient_proposal_path(@recipient), current_path
  end

  test 'redirect to new proposal if no proposal found' do
    assert_equal 0, @recipient.proposals.count
    check_path(recommended_funders_path)
    check_path(all_funders_path)
    check_path(eligible_funders_path)
    check_path(ineligible_funders_path)
    check_path(edit_recipient_proposal_path(@recipient))
    check_path(recipient_proposals_path(@recipient))
  end

  def complete_inital_proposal
    proposal = create(:initial_proposal, recipient: @recipient, countries: @countries, districts: @districts, age_groups: @age_groups, beneficiaries: @beneficiaries)
    visit recommended_funders_path
    assert_equal edit_recipient_proposal_path(@recipient, proposal), current_path
    assert_equal proposal.total_costs.to_s, find('#proposal_total_costs')[:value]
    select(Proposal::FUNDING_TYPE.sample, from: 'proposal_funding_type')
    choose('proposal_affect_other_false')
    within('.proposal_private') do
      choose('Yes')
    end
    click_button 'Save and recommend funders'
    assert_equal recommended_funders_path, current_path
  end

  test 'current profile redirects to edit proposal if proposal inital' do
    create(:current_profile, organisation: @recipient, countries: @countries, districts: @districts, age_groups: @age_groups, beneficiaries: @beneficiaries)
    complete_inital_proposal
  end

  test 'legacy profile redirects to edit proposal if proposal inital' do
    legacy_profile = build(:legacy_profile, organisation: @recipient, countries: @countries, districts: @districts, age_groups: @age_groups, beneficiaries: @beneficiaries)
    legacy_profile.save(validate: false)
    complete_inital_proposal
  end

  def assert_profile_transferred
    visit recommended_funders_path
    assert_equal new_recipient_proposal_path(@recipient), current_path
    assert_equal 'Other', find('#proposal_gender')[:value]
  end

  test 'transferred proposal populated from current profile if no proposal' do
    create(:current_profile, organisation: @recipient, gender: 'Other', countries: @countries, districts: @districts, age_groups: @age_groups, beneficiaries: @beneficiaries)
    assert_profile_transferred
  end

  test 'transferred proposal populated from legacy profile if no proposal' do
    legacy_profile = build(:legacy_profile, organisation: @recipient, gender: 'Other', countries: @countries, districts: @districts, age_groups: @age_groups, beneficiaries: @beneficiaries)
    legacy_profile.save(validate: false)
    assert_profile_transferred
  end

  test 'beneficiary_other and implementor_other transferred' do
    profile = create(:current_profile, organisation: @recipient, beneficiaries_other: 'Beneficiaries', beneficiaries_other_required: true, implementations_other: 'Implementations', implementations_other_required: true, countries: @countries, districts: @districts, age_groups: @age_groups, beneficiaries: @beneficiaries)
    proposal = build(:initial_proposal, recipient: @recipient, countries: @countries, districts: @districts)
    @recipient.transfer_profile_to_new_proposal(profile, proposal)
    visit recommended_funders_path
    # assert page.has_css?('#proposal_beneficiaries_other_required:checked')
    assert_equal 'Beneficiaries', find('#proposal_beneficiaries_other')[:value]
    # assert page.has_css?('#proposal_implementations_other_required:checked')
    assert_equal 'Implementations', proposal.implementations_other
  end

  test 'implementors transferred' do
    profile = create(:current_profile, organisation: @recipient, countries: @countries, districts: @districts, age_groups: @age_groups, beneficiaries: @beneficiaries)
    proposal = build(:initial_proposal, recipient: @recipient, implementations: Implementation.all, countries: @countries, districts: @districts, age_groups: @age_groups, beneficiaries: @beneficiaries)
    visit recommended_funders_path
    assert_equal profile.implementations.pluck(:id), proposal.implementation_ids
  end

  def create_invalid_recipient(charity_number)
    User.destroy_all
    Recipient.destroy_all
    @recipient = build(:legacy_recipient, charity_number: charity_number)
    @recipient.set_slug
    @recipient.save(validate: false)
    create_and_auth_user!(organisation: @recipient)
  end

  test 'invalid recipient must be completed before proposal or recommendations' do
    create_invalid_recipient('1161998')

    visit recommended_funders_path
    assert_equal edit_recipient_path(@recipient), current_path

    visit new_recipient_proposal_path(@recipient)
    assert_equal edit_recipient_path(@recipient), current_path

    assert_equal 'Centre For The Acceleration Of Social Technology', find('#recipient_name')[:value]
  end

  test 'invalid recipient with complete scrape redirects to new proposal' do
    create_invalid_recipient('326568')

    visit root_path
    assert_equal new_recipient_proposal_path(@recipient), current_path
  end

  test 'profile for migration shows cta' do
    profile = build(:legacy_profile, organisation: @recipient, countries: @countries, districts: @districts, age_groups: @age_groups, beneficiaries: @beneficiaries)
    profile.save(validate: false)
    visit edit_recipient_path(@recipient)
    assert page.has_content?('Your details are out of date')
  end

  test 'cannot create second proposal until first complete' do
    proposal = create(:registered_proposal, recipient: @recipient, countries: @countries, districts: @districts, age_groups: @age_groups, beneficiaries: @beneficiaries)
    visit new_recipient_proposal_path(@recipient)
    assert_equal edit_recipient_proposal_path(@recipient, proposal), current_path
    assert page.has_content?('fully complete your funding proposal')
  end

  test 'cannot check eligibility until first proposal is complete' do
    proposal = create(:registered_proposal, recipient: @recipient, countries: @countries, districts: @districts, age_groups: @age_groups, beneficiaries: @beneficiaries)
    visit recipient_eligibility_path(@funders[0])
    assert_equal edit_recipient_proposal_path(@recipient, proposal), current_path
    assert page.has_content?('fully complete your funding proposal')

    proposal.update_attribute(:state, 'complete')
    visit recipient_eligibility_path(@funders[0])
    assert_equal recipient_eligibility_path(@funders[0]), current_path
  end

  test 'cannot apply until first proposal is complete' do
    proposal = create(:proposal, recipient: @recipient, countries: @countries, districts: @districts, age_groups: @age_groups, beneficiaries: @beneficiaries)
    visit recipient_apply_path(@funders[0])
    assert_equal recipient_eligibility_path(@funders[0]), current_path

    @recipient.set_eligibility(@funders[0], 'Eligible')
    visit recipient_apply_path(@funders[0])
    assert_equal recipient_apply_path(@funders[0]), current_path
  end

  test 'redirect to edit incomplete first proposal if not complete' do
    registered_proposal = create(:registered_proposal, recipient: @recipient, countries: @countries, districts: @districts, age_groups: @age_groups, beneficiaries: @beneficiaries)
    visit new_recipient_proposal_path(@recipient)
    assert_equal edit_recipient_proposal_path(@recipient, registered_proposal), current_path
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
    within('.proposal_private') do
      choose('Yes')
    end

    choose('An entire country')
    select(Country.first.name, from: 'proposal_country_ids', match: :first) # javascript
  end

  test 'can create inital proposal' do
    @initial_proposal = build(:initial_proposal, recipient: @recipient, countries: @countries, districts: @districts, age_groups: @age_groups, beneficiaries: @beneficiaries)

    visit new_recipient_proposal_path(@recipient)
    within('#new_proposal') do
      initial_complete_form
    end
    click_button 'Save and recommend funders'

    assert_equal false, @initial_proposal.private
    assert_equal recommended_funders_path, current_path
    assert page.has_content? 'Recommended funders'
  end

  test 'funder insights reflect proposal comparison' do
    create(:registered_proposal, recipient: @recipient, countries: @countries, districts: @districts, age_groups: @age_groups, beneficiaries: @beneficiaries)
    visit recommended_funders_path

    assert page.has_content? "amount you're seeking", count: 3
    assert page.has_content? "duration you're seeking", count: 3
  end

  test 'only registered fields shown when registered' do
    proposal = create(:registered_proposal, recipient: @recipient, countries: @countries, districts: @districts, age_groups: @age_groups, beneficiaries: @beneficiaries)
    visit edit_recipient_proposal_path(@recipient, proposal)

    assert page.has_content?('Summary')
    assert page.has_content?('Activities')
    assert page.has_content?('Outcomes')
    assert_not page.has_content?('Requirements')
    assert_not page.has_content?('Beneficiaries')
    assert_not page.has_content?('Location')
    assert page.has_content?('Privacy', count: 1)
  end

  test 'all fields shown when proposal complete' do
    proposal = create(:proposal, recipient: @recipient, countries: @countries, districts: @districts, age_groups: @age_groups, beneficiaries: @beneficiaries)
    visit edit_recipient_proposal_path(@recipient, proposal)
    assert page.has_content?('Summary')
    assert page.has_content?('Requirements')
    assert page.has_content?('Beneficiaries')
    assert page.has_content?('Location')
    assert page.has_content?('Activities')
    assert page.has_content?('Outcomes')
    assert page.has_content?('Privacy', count: 2)
  end

  test 'redirected to eligibility if return to' do
    proposal = create(:registered_proposal, recipient: @recipient, countries: @countries, districts: @districts, age_groups: @age_groups, beneficiaries: @beneficiaries)
    visit recipient_eligibility_path(@funders[0])

    assert_not page.has_content?('Update and review recommendations')
    click_button('Update and check eligibility')
    assert_equal recipient_eligibility_path(@funders[0]), current_path
  end

  test 'redirected to recommended funders if no return to' do
    proposal = create(:registered_proposal, recipient: @recipient, countries: @countries, districts: @districts, age_groups: @age_groups, beneficiaries: @beneficiaries)
    visit recipient_proposals_path(@recipient)
    click_link('Update proposal')
    click_button('Update and review recommendations')
    assert_equal recommended_funders_path, current_path
  end

end

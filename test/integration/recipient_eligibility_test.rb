require 'test_helper'

class RecipientEligibilityTest < ActionDispatch::IntegrationTest

  setup do
    @recipient = create(:recipient)
    @funder = create(:funder)
    @recipient.unlock_funder!(@funder)
  end

  test "recipient no eligibility data has to complete all questions" do
    @restrictions = 3.times { create(:restriction, :funders => [@funder]) }

    create_and_auth_user!(:organisation => @recipient)
    visit "/comparison/#{@funder.slug}"
    click_link('Are you a good fit?')

    assert_equal "/#{@funder.slug}/eligibility", current_path
    assert page.has_content?("Are you seeking funding for", count: 3)
  end

  test "recipient with no eligibility data cannot visit new enquiry page and redirected to eligibility page" do
    @restrictions = 3.times { create(:restriction, :funders => [@funder]) }

    create_and_auth_user!(:organisation => @recipient)
    visit "/funders/#{@funder.slug}/enquiries/new"

    assert_equal "/#{@funder.slug}/eligibility", current_path
    assert page.has_content?("Are you seeking funding for", count: 3)
  end

  test "recipient with partial eligibility data able to fill gaps" do
    @restriction1 = create(:restriction, :funders => [@funder])
    @restriction2 = create(:restriction, :funders => [@funder])
    @restriction3 = create(:restriction, :funders => [@funder])

    @eligibility1 = create(:eligibility, :recipient => @recipient, :restriction => @restriction1)
    @eligibility2 = create(:eligibility, :recipient => @recipient, :restriction => @restriction2)

    create_and_auth_user!(:organisation => @recipient)
    visit "/comparison/#{@funder.slug}"
    click_link('Are you a good fit?')

    assert_equal "/#{@funder.slug}/eligibility", current_path
    assert page.has_content?("Are you seeking funding for", count: 1)
  end

  test "recipient with partial eligibility data cannot visit new enquiry page and redirected to eligibility page" do
    @restriction1 = create(:restriction, :funders => [@funder])
    @restriction2 = create(:restriction, :funders => [@funder])
    @restriction3 = create(:restriction, :funders => [@funder])

    @eligibility1 = create(:eligibility, :recipient => @recipient, :restriction => @restriction1)
    @eligibility2 = create(:eligibility, :recipient => @recipient, :restriction => @restriction2)

    create_and_auth_user!(:organisation => @recipient)
    visit "/funders/#{@funder.slug}/enquiries/new"

    assert_equal "/#{@funder.slug}/eligibility", current_path
    assert page.has_content?("Are you seeking funding for", count: 1)
  end

  test "recipient with all eligibility data redirected to new enquiry page" do
    @restriction1 = create(:restriction, :funders => [@funder])
    @restriction2 = create(:restriction, :funders => [@funder])
    @restriction3 = create(:restriction, :funders => [@funder])

    @eligibility1 = create(:eligibility, :recipient => @recipient, :restriction => @restriction1)
    @eligibility2 = create(:eligibility, :recipient => @recipient, :restriction => @restriction2)
    @eligibility3 = create(:eligibility, :recipient => @recipient, :restriction => @restriction3)

    create_and_auth_user!(:organisation => @recipient)
    visit "/comparison/#{@funder.slug}"
    click_link('Are you a good fit?')

    assert_equal "/funders/#{@funder.slug}/enquiries/new", current_path
  end

  test "inelligible recipient redirected to comparison page" do
    @restriction1 = create(:restriction, :funders => [@funder])
    @restriction2 = create(:restriction, :funders => [@funder])
    @restriction3 = create(:restriction, :funders => [@funder])

    create_and_auth_user!(:organisation => @recipient)
    visit "/comparison/#{@funder.slug}"
    click_link('Are you a good fit?')

    select('Yes', :from => 'recipient_eligibilities_attributes_0_eligible')
    select('No', :from => 'recipient_eligibilities_attributes_1_eligible')
    select('No', :from => 'recipient_eligibilities_attributes_2_eligible')

    click_button('Check')

    assert_equal "/comparison/#{@funder.slug}", current_path

    visit "/funders/#{@funder.slug}/enquiries/new"
    assert_equal "/comparison/#{@funder.slug}", current_path
  end

  test "ineligible recipient cannot visit eligibility page" do
    @restriction1 = create(:restriction, :funders => [@funder])
    @restriction2 = create(:restriction, :funders => [@funder])
    @restriction3 = create(:restriction, :funders => [@funder])

    @eligibility1 = create(:eligibility, :eligible => false, :recipient => @recipient, :restriction => @restriction1)
    @eligibility2 = create(:eligibility, :recipient => @recipient, :restriction => @restriction2)
    @eligibility3 = create(:eligibility, :recipient => @recipient, :restriction => @restriction3)

    create_and_auth_user!(:organisation => @recipient)
    visit "/#{@funder.slug}/eligibility"

    assert_equal "/comparison/#{@funder.slug}", current_path
  end

  test "ineligible recipient cannot visit enquiry page" do
    @restriction1 = create(:restriction, :funders => [@funder])
    @restriction2 = create(:restriction, :funders => [@funder])
    @restriction3 = create(:restriction, :funders => [@funder])

    @eligibility1 = create(:eligibility, :eligible => false, :recipient => @recipient, :restriction => @restriction1)
    @eligibility2 = create(:eligibility, :recipient => @recipient, :restriction => @restriction2)
    @eligibility3 = create(:eligibility, :recipient => @recipient, :restriction => @restriction3)

    create_and_auth_user!(:organisation => @recipient)
    visit "/funders/#{@funder.slug}/enquiries/new"

    assert_equal "/comparison/#{@funder.slug}", current_path
  end

end

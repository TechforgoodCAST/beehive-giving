require 'test_helper'

class RecipientEligibilityTest < ActionDispatch::IntegrationTest

  setup do
    @recipient = create(:recipient)
    @funder = create(:funder)
    @recipient.unlock_funder!(@funder)
    @attribute = create(:recipient_attribute, recipient: @recipient)
    @profile = create(:profile, :organisation => @recipient, :year => Date.today.year)
    @restrictions = Array.new(3) { |i| create(:restriction) }
    @eligibilities = Array.new(3) { |i| create(:eligibility, :recipient => @recipient, :restriction => @restrictions[i]) }
  end

  test "recipient no eligibility data has to complete all questions" do
    @funding_stream = create(:funding_stream, :restrictions => @restrictions, :funders => [@funder])

    @eligibilities.each { |e| e.destroy }

    create_and_auth_user!(:organisation => @recipient)
    visit recipient_comparison_path(@funder)
    click_link('Check eligibility')

    assert_equal recipient_eligibility_path(@funder), current_path
    assert page.has_content?("Are you seeking funding for", count: 3)
  end

  test "recipient with partial eligibility data able to fill gaps" do
    @funding_stream = create(:funding_stream, :restrictions => @restrictions, :funders => [@funder])

    @eligibilities.last.destroy

    create_and_auth_user!(:organisation => @recipient)
    visit recipient_comparison_path(@funder)
    click_link('Check eligibility')

    assert_equal recipient_eligibility_path(@funder), current_path
    assert page.has_content?("Are you seeking funding for", count: 1)
  end

  test "recipient with all eligibility data has eligibility modal" do
    @funding_stream = create(:funding_stream, :restrictions => @restrictions, :funders => [@funder], :label => 'All')
    @funder_attribute = create(:funder_attribute, :funder => @funder, :funding_stream => 'All', :grant_count => 1)

    create_and_auth_user!(:organisation => @recipient)
    visit recipient_comparison_path(@funder)
    assert page.has_content?("Things to consider")
  end

  test "ineligible recipient cannot visit eligibility check page" do
    @funding_stream = create(:funding_stream, :restrictions => @restrictions, :funders => [@funder])

    @eligibilities[0].update_column(:eligible, false)

    create_and_auth_user!(:organisation => @recipient)
    visit recipient_eligibility_path(@funder)

    assert_equal recipient_comparison_path(@funder), current_path
  end

  test "cannot check eligibility if funder locked" do
    create_and_auth_user!(:organisation => @recipient)
    RecipientFunderAccess.where(recipient_id: @recipient.id, funder_id: @funder.id).first.destroy
    visit recipient_eligibility_path(@funder)
    assert_equal recipient_comparison_path(@funder), current_path
  end

  test "inverted restrictions set yes as true" do
    create(:profile, :organisation => @recipient)

    @restrictions[1].update_column(:invert, true)
    @eligibilities.each { |e| e.destroy }

    @funding_stream = create(:funding_stream, :restrictions => @restrictions, :funders => [@funder], :label => 'All')
    @funder_attribute = create(:funder_attribute, :funder => @funder, :funding_stream => 'All', :grant_count => 1)

    create_and_auth_user!(:organisation => @recipient)
    visit recipient_eligibility_path(@funder)

    within("#edit_recipient_#{@recipient.id}") do
      select('No', :from => "recipient_eligibilities_attributes_0_eligible")
      select('Yes', :from => "recipient_eligibilities_attributes_1_eligible")
      select('No', :from => "recipient_eligibilities_attributes_2_eligible")
    end
    click_button('Check eligibility')

    assert page.has_content?("You're eligible", count: 1)
  end

end

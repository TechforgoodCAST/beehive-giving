require 'test_helper'

class RecipientGatewayTest < ActionDispatch::IntegrationTest

  setup do
    @funders = Array.new(5) {|i| create(:funder, name: "funder#{i}")}
    @recipient = create(:recipient)
  end

  test "recipient with one profile for current year can unlock 3 funders" do
    @recipient.founded_on = "#{Date.today.year-10}/01/01"
    create_and_auth_user!(:organisation => @recipient)
    create(:feedback, :user => @recipient.users.first)

    # Cannot unlock funders without one profile
    visit recipient_comparison_path(@funders[0])
    assert_equal recipient_comparison_gateway_path(@funders[0]), current_path

    # Create one profile for current year
    create(:profile, :organisation => @recipient, :year => Date.today.year )

    # First unlock
    visit recipient_comparison_gateway_path(@funders[0])
    click_link("Unlock Funder (#{Recipient::MAX_FREE_LIMIT} left)")
    assert_equal recipient_comparison_path(@funders[0]), current_path

    # Second unlock
    create(:profile, :organisation => @recipient, :year => (Date.today.year - 1) )
    visit recipient_comparison_gateway_path(@funders[1])
    click_link("Unlock Funder (#{Recipient::MAX_FREE_LIMIT - 1} left)")
    assert_equal recipient_comparison_path(@funders[1]), current_path

    # Third unlock
    create(:profile, :organisation => @recipient, :year => (Date.today.year - 2) )
    visit recipient_comparison_gateway_path(@funders[2])
    click_link("Unlock Funder (#{Recipient::MAX_FREE_LIMIT - 2} left)")
    assert_equal recipient_comparison_path(@funders[2]), current_path

    # Fouth unlock not permitted
    visit recipient_comparison_gateway_path(@funders[4])
    assert page.has_content?("You can only unlock #{Recipient::MAX_FREE_LIMIT} funders at the moment")
  end

  test "Eligibilty modal shown when first funder unlocked on first funders page" do
    create(:profile, :organisation => @recipient)
    create(:funding_stream, :restrictions => Array.new(3) { |i| create(:restriction) }, :funders => [@funders[0]])
    create_and_auth_user!(:organisation => @recipient)

    visit recipient_comparison_gateway_path(@funders[0])
    click_link("Unlock Funder")
    assert page.has_css?("#eligibility")
  end

  test "Eligibilty modal hidden if first funder eligibility complete" do
    create(:profile, :organisation => @recipient)
    @restrictions = Array.new(3) { |i| create(:restriction) }
    create(:funding_stream, :restrictions => @restrictions, :funders => [@funders[0]])
    create(:funder_attribute, :funder => @funders[0], :funding_stream => 'All')
    create_and_auth_user!(:organisation => @recipient)

    visit recipient_comparison_gateway_path(@funders[0])
    click_link("Unlock Funder")
    assert page.has_css?("#eligibility")

    3.times { |i| create(:eligibility, :recipient => @recipient, :restriction => @restrictions[i])}

    visit recipient_comparison_gateway_path(@funders[0])
    assert_not page.has_css?("#eligibility")

    visit recipient_comparison_gateway_path(@funders[1])
    assert_not page.has_css?("#eligibility")
  end

end

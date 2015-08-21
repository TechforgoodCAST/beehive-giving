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

    @grants = Array.new(5) { |i| create(:grants, :funder => @funders[i], :recipient => @recipient) }
    @attributes = Array.new(5) { |i| create(:funder_attribute, :funder => @funders[i]) }
    @restrictions = Array.new(3) { |i| create(:restriction) }
    @funding_streams = Array.new(5) { |i| create(:funding_stream, :restrictions => @restrictions, :funders => [@funders[i]]) }

    # Cannot unlock funders without one profile
    visit recipient_comparison_path(@funders[0])
    assert page.has_content?("Recommend funders")

    # Create one profile for current year
    create(:profile, :organisation => @recipient, :year => Date.today.year )

    # First unlock
    visit recipient_comparison_path(@funders[0])
    click_link("Check eligibility (#{Recipient::MAX_FREE_LIMIT} left)")
    assert_equal recipient_eligibility_path(@funders[0]), current_path

    # Second unlock
    visit recipient_comparison_path(@funders[1])
    puts page.body
    click_link("Check eligibility (#{Recipient::MAX_FREE_LIMIT - 1} left)")
    assert_equal recipient_eligibility_path(@funders[1]), current_path

    # Third unlock
    visit recipient_comparison_path(@funders[2])
    click_link("Check eligibility (#{Recipient::MAX_FREE_LIMIT - 2} left)")
    assert_equal recipient_eligibility_path(@funders[2]), current_path

    # Fouth unlock not permitted
    visit recipient_comparison_path(@funders[4])
    assert page.has_content?("You can only check your eligibility with #{Recipient::MAX_FREE_LIMIT} funders at the moment.")
  end

end

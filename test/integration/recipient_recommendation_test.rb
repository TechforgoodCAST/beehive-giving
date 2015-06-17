require "test_helper"

class RecipientRecommendationTest < ActionDispatch::IntegrationTest

  setup do
    @funders = Array.new(3){ |i| create(:funder, :active_on_beehive => true) }
    @recipient = create(:recipient)

    create(:grants, :funder => @funders[0], :recipient => @recipient)
    create(:grants, :funder => @funders[1], :recipient => @recipient, :countries => FactoryGirl.create_list(:country, 4))
    create(:grants, :funder => @funders[2], :recipient => @recipient)

    @funder_attribute = Array.new(3){ |i| create(:funder_attribute, :funder => @funders[i], :funding_stream => "All") }
    @funder_attribute[1].countries = FactoryGirl.create_list(:country, 4)
    @funder_attribute[2].beneficiaries = FactoryGirl.create_list(:beneficiary_unique, 4)
    create_and_auth_user!(:organisation => @recipient)
  end

  test "funders order by initial recommendation" do
    visit "/funders"
    Capybara.match = :first
    click_link("See how you compare (Locked)")
    assert_equal "/comparison/#{@funders[1].slug}/gateway", current_path
  end

  test "funders order by refined recommendation" do
    create(:profile, :organisation => @recipient, :beneficiaries => FactoryGirl.create_list(:beneficiary_unique, 4))
    @recipient.refined_recommendation
    visit "/funders"
    Capybara.match = :first
    click_link("See how you compare (Locked)")
    assert_equal "/comparison/#{@funders[2].slug}/gateway", current_path
  end

end

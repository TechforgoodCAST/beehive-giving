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

  test "funders order by refined recommendation" do
    create(:profile, :organisation => @recipient, :beneficiaries => FactoryGirl.create_list(:beneficiary_unique, 4), :state => 'complete')
    @recipient.refined_recommendation
    visit funders_path
    Capybara.match = :first
    click_link("#locked_funder")
    assert_equal recipient_comparison_path(@funders[2]), current_path
  end

  test "closed funder is not recommended" do
    recommendation = @recipient.recommendations.where(funder_id: @funders[0].id).first

    @recipient.refined_recommendation
    assert_not recommendation.score == 0

    @funders[0].name = 'Cripplegate Foundation'
    @recipient.refined_recommendation
    recommendation = @recipient.recommendations.where(funder_id: @funders[0].id).first

    assert_equal 0, recommendation.score
  end

end

require "test_helper"

class RecipientRecommendationTest < ActionDispatch::IntegrationTest

  setup do
    @recipient = create(:recipient)
    setup_funders(3, true)
  end

  test 'funders order by recommendation score' do
    visit funders_path
    Capybara.match = :first
    click_link('More info')
    assert_equal funder_path(@funders[2]), current_path
  end

  test 'closed funder is not recommended' do
    Funder.last.update_column(:name, 'Cripplegate Foundation')
    @proposal.save
    visit recommended_funders_path
    assert page.has_css?('.funder', count: 2)
    assert_equal 0, @recipient.load_recommendation(Funder.last).score
  end

  test 'closing funder updates historic recommendations' do
    skip
  end

  test 'org_type recommendation set' do
    test_data = []
    @funders.each { |f| test_data << [f.id, 2] }
    assert_equal test_data, @recipient.recommendations.order(:funder_id).pluck(:funder_id, :org_type_score)
  end

  test 'beneficiary recommendation set' do
    test_data = [
      [@funders[0].id, 1.33333333333333],
      [@funders[1].id, 1.66666666666667],
      [@funders[2].id, 2.0]
    ]
    assert_equal test_data, @recipient.recommendations.order(:funder_id).pluck(:funder_id, :beneficiary_score)
  end

  test 'location recommendation set' do
    test_data = []
    @funders.each { |f| test_data << [f.id, 0.266666666666667] }
    assert_equal test_data, @recipient.recommendations.order(:funder_id).pluck(:funder_id, :location_score)
  end

  test 'requirements recommendation set' do
    test_data = []
    @funders.each { |f| test_data << [f.id, 1, 1] }
    assert_equal test_data, @recipient.recommendations.order(:funder_id).pluck(:funder_id, :grant_amount_recommendation, :grant_duration_recommendation)
  end

  test 'total recommendation set' do
    test_data = [
      [@funders[0].id, 3.6],
      [@funders[1].id, 3.93333333333333],
      [@funders[2].id, 4.26666666666667]
    ]
    assert_equal test_data, @recipient.recommendations.order(:funder_id).pluck(:funder_id, :score)
  end

  test 'updating proposal updates recommendations' do
    @proposal.beneficiaries = []
    @proposal.save(validate: false)
    test_data = [
      [@funders[0].id, 1.33333333333333],
      [@funders[1].id, 1.66666666666667],
      [@funders[2].id, 2.0]
    ]
    assert_not_equal test_data, @recipient.recommendations.order(:funder_id).pluck(:funder_id, :score)
  end

  test 'different proposals have different recommendations' do
    skip
  end

end

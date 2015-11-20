require 'test_helper'

class RecipientEligibilityTest < ActionDispatch::IntegrationTest

  setup do
    @recipient = create(:recipient)
    @funder = create(:funder)
    3.times { |g| create(:grant, funder: @funder) }
    create(:funder_attribute, funder: @funder)
    create(:profile, organisation: @recipient, year: Date.today.year, state: 'complete')
    @restrictions = Array.new(3) { |i| create(:restriction) }
    Array.new(3) { |i| create(:eligibility, recipient: @recipient, restriction: @restrictions[i]) }
    create_and_auth_user!(organisation: @recipient)
    @recipient.recommendations.first.update_attribute(:score, 2)
  end

  test 'recipient no eligibility data has to complete all questions' do
    Capybara.match = :first

    @funding_stream = create(:funding_stream, :restrictions => @restrictions, :funders => [@funder])
    Eligibility.destroy_all

    visit funder_path(@funder)
    click_link('Check eligibility')

    assert_equal recipient_eligibility_path(@funder), current_path
    assert page.has_content?('Yes', count: 3)
  end

  test 'recipient with partial eligibility data able to fill gaps' do
    create(:funding_stream, restrictions: @restrictions, funders: [@funder])
    Eligibility.last.destroy

    visit recipient_eligibility_path(@funder)
    assert page.has_content?('Yes', count: 1)
  end

  test 'eligible recipient can apply for funding' do
    @recipient.recommendations.last.update_attribute(:eligibility, 'Eligible')

    visit recipient_apply_path(@funder)
    assert_equal recipient_apply_path(@funder), current_path
  end

  test 'ineligible recipient cannot visit apply for funding page' do
    @recipient.recommendations.last.update_attributes(eligibility: 'Ineligible')

    visit recipient_apply_path(@funder)
    assert_equal recipient_eligibility_path(@funder), current_path
  end

  test 'cannot check eligibility if max free limit reached unless subscribed' do
    4.times { |f| create(:funder) }
    Funder.all.limit(3).each { |f| @recipient.unlock_funder!(f) }
    @recipient.refined_recommendation

    visit recipient_eligibility_path(Funder.first)
    assert_equal recipient_eligibility_path(Funder.first), current_path

    visit recipient_eligibility_path(Funder.last)
    assert_equal recommended_funders_path, current_path

    # refactor test unless subscribed
  end

end

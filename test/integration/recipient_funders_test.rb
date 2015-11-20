require 'test_helper'

class RecipientFundersTest < ActionDispatch::IntegrationTest

  setup do
    @recipient = create(:recipient)
    create(:profile, organisation: @recipient, state: 'complete')
  end

  test 'cannot view funder if not active' do
    funder = create(:funder, active_on_beehive: false)
    create_and_auth_user!(organisation: @recipient)

    visit funder_path(funder)
    assert_equal recommended_funders_path, current_path
  end

  # test 'recommended funders path only shows recommended and eligible funders' do
  #   setup_funders
  #   visit recommended_funders_path
  #   assert false
  # end

  test 'eligible funders path only shows eligible funders' do
    setup_funders(3)
    visit eligible_funders_path
    assert_not page.has_content?('More info')
    @recipient.load_recommendation(@funders.first).update_attribute(:eligibility, 'Eligible')
    visit eligible_funders_path
    assert page.has_content?('More info', count: 1)
  end

  test 'ineligible funders path only shows eligible funders' do
    setup_funders(3)
    visit ineligible_funders_path
    assert_not page.has_content?('More info')
    @recipient.load_recommendation(@funders.first).update_attribute(:eligibility, 'Ineligible')
    visit ineligible_funders_path
    assert page.has_content?('More info', count: 1)
  end

  test 'all funders path shows all funders' do
    setup_funders(7)
    visit funders_path
    assert page.has_css?('.funder', count: Funder.where(active_on_beehive: true).count)
  end

  test 'cannot visit redacted funder unless subscribed' do
    setup_funders(7)
    visit funder_path(@funders.last)
    assert_equal recommended_funders_path, current_path
    # refactor unless subscribed
  end

  # test 'cannot check redacted funder unless subscribed' do
  #   setup_funders(7)
  #   visit recipient_eligibility_path(@funders.last)
  #   assert_equal recommended_funders_path, current_path
  #   assert false
  # end

  # test 'redacted funder redirects to upgrade path unless subscribed' do
  #   refactor unless subscribed
  #   assert false
  # end

  # test 'approved on hidden if all grants on 1st of jan' do
  # end

  # test 'funder attributes with no grants are not displayed' do
  # end

  # refactor needed?
  # test 'funders are locked for recipients with no profiles' do
  #   3.times do |i|
  #     @funder = create(:funder, active_on_beehive: true)
  #     create(:funder_attribute, funder: @funder, funding_stream: 'All')
  #     @restrictions = Array.new(3) { |i| create(:restriction) }
  #     @funding_stream = create(:funding_stream, restrictions: @restrictions, funders: [@funder])
  #   end
  #
  #   create_and_auth_user!(organisation: @recipient)
  #   visit funders_path
  #   assert_not page.has_content?('Check eligibility')
  #   assert_equal all('.funder').length, 3
  # end

  # test 'Must have profile for current year to check eligibility' do
  #   setup_funders
  #   create(:profile, organisation: @recipient, year: Date.today.year-1 )
  #   create_and_auth_user!(organisation: @recipient)
  #   visit funder_path(@funders[0])
  #   assert page.has_content?('Before you continue')
  # end
  #
  # test 'recipients only needs to create one profile for current year to unlock funders' do
  #   setup_funders
  #   create(:profile, :organisation => @recipient, :year => Date.today.year )
  #   create_and_auth_user!(:organisation => @recipient)
  #
  #   visit recipient_eligibility_path(@funders[0])
  #   assert page.has_content?('Check eligibility (3 left)')
  #   select('No', :from => 'recipient_eligibilities_attributes_0_eligible')
  #   select('No', :from => 'recipient_eligibilities_attributes_1_eligible')
  #   select('No', :from => 'recipient_eligibilities_attributes_2_eligible')
  #   click_button('Check eligibility (3 left)')
  #   assert page.has_content?("You're eligible for one")
  #
  #   @funding_streams[1].restrictions << create(:restriction)
  #   visit recipient_eligibility_path(@funders[1])
  #   assert page.has_content?('Check eligibility (2 left)')
  # end
  #
  # test 'recipient can only unlock 3 funders without subscribing' do
  #   @funders = Array.new(4) { |i| create(:funder, :active_on_beehive => true) }
  #   Array.new(4) { |i| create(:funder_attribute, :funder => @funders[i], :funding_stream => "All", :grant_count => 1) }
  #
  #   @profile = create(:profile, :organisation => @recipient)
  #   3.times { |i| @recipient.unlock_funder!(@funders[i]) }
  #
  #   create_and_auth_user!(:organisation => @recipient)
  #   visit recipient_comparison_path(@funders[3])
  #
  #   assert_not page.has_link?('Unlock Funder')
  # end
  #
  # def eligible_badge
  #   @recipient = create(:recipient, founded_on: "01/01/2005")
  #   @funders, @restrictions = [], []
  #
  #   3.times do |i|
  #     @funder = create(:funder, :active_on_beehive => true)
  #     @funders << @funder
  #     create(:funder_attribute, :funder => @funder, :funding_stream => "All")
  #   end
  #
  #   create(:profile, :organisation => @recipient, :year => Date.today.year, :state => 'complete')
  #
  #   3.times { |i| @recipient.unlock_funder!(@funders[i]) }
  # end
  #
  # def recommend_all_funders
  #   Recommendation.all.each { |r| r.update_column(:score, Recipient::RECOMMENDATION_THRESHOLD)}
  # end
  #
  # test 'no eligibility badge if questions remaining' do
  #   eligible_badge
  #
  #   3.times do |i|
  #     @restrictions << create(:restriction)
  #     @funding_stream = create(:funding_stream, :restrictions => @restrictions, :funders => [@funders[i]])
  #   end
  #
  #   2.times do |i|
  #     @eligibility = create(:eligibility, :recipient => @recipient, :restriction => @restrictions[i])
  #   end
  #
  #   create_and_auth_user!(:organisation => @recipient)
  #   recommend_all_funders
  #   visit funders_path
  #
  #   assert page.has_content?('Eligible', count: 2)
  #   assert page.has_content?('Not eligible', count: 0)
  # end
  #
  # test 'eligible badge if recipient eligible' do
  #   eligible_badge
  #
  #   3.times do |i|
  #     @restrictions << create(:restriction)
  #     @funding_stream = create(:funding_stream, :restrictions => @restrictions, :funders => [@funders[i]])
  #     @eligibility = create(:eligibility, :recipient => @recipient, :restriction => @restrictions[i])
  #   end
  #
  #   create_and_auth_user!(:organisation => @recipient)
  #   recommend_all_funders
  #   visit funders_path
  #
  #   assert page.has_content?('Eligible', count: 3)
  #   assert page.has_content?('Not eligible', count: 0)
  # end
  #
  # test 'not eligible badge if recipient no eligible' do
  #   eligible_badge
  #
  #   3.times do |i|
  #     @restrictions << create(:restriction)
  #     @funding_stream = create(:funding_stream, :restrictions => @restrictions, :funders => [@funders[i]])
  #     @eligibility = create(:eligibility, :eligible => false, :recipient => @recipient, :restriction => @restrictions[i])
  #   end
  #
  #   create_and_auth_user!(:organisation => @recipient)
  #   recommend_all_funders
  #   visit funders_path
  #
  #   assert page.has_content?('Eligible', count: 0)
  #   assert page.has_content?('Not eligible', count: 3)
  # end
  #
  # test 'Welcome modal shows if no profile' do
  #   create_and_auth_user!(:organisation => @recipient)
  #   visit funders_path
  #   assert_equal 0, @recipient.profiles.count
  #   assert page.has_css?("#welcome")
  # end

end

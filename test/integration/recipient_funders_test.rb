require 'test_helper'

class RecipientFundersTest < ActionDispatch::IntegrationTest

  setup do
    @recipient = create(:recipient)
  end

  test 'funders are locked for recipients with no profiles' do
    3.times do |i|
      @funder = create(:funder, :active_on_beehive => true)
      create(:funder_attribute, :funder => @funder, :funding_stream => "All")
    end

    create_and_auth_user!(:organisation => @recipient)
    visit funders_path
    assert page.has_content?("See how you compare")
    assert_equal all(".uk-icon-lock").length, 3
  end

  test 'recipients only needs to create one profile to unlock funders' do
    @funders = Array.new(3) { |i| create(:funder, :active_on_beehive => true) }
    Array.new(3) { |i| create(:funder_attribute, :funder => @funders[i], :funding_stream => "All", :grant_count => 1) }

    @profile = create(:profile, :organisation => @recipient)
    create_and_auth_user!(:organisation => @recipient)

    visit recipient_comparison_path(@funders[0])
    assert page.has_link?('Unlock Funder')
    find_link('Unlock Funder').click

    visit recipient_comparison_path(@funders[1])
    assert page.has_link?('Unlock Funder')
    find_link('Unlock Funder').click
  end

  test 'recipient can only unlock 3 funders without subscribing' do
    @funders = Array.new(4) { |i| create(:funder, :active_on_beehive => true) }
    Array.new(4) { |i| create(:funder_attribute, :funder => @funders[i], :funding_stream => "All", :grant_count => 1) }

    @profile = create(:profile, :organisation => @recipient)
    3.times { |i| @recipient.unlock_funder!(@funders[i]) }

    create_and_auth_user!(:organisation => @recipient)
    visit recipient_comparison_path(@funders[3])

    assert_not page.has_link?('Unlock Funder')
  end

  def eligible_badge
    @recipient = create(:recipient, founded_on: "01/01/2005")
    @funders, @restrictions = [], []

    3.times do |i|
      @funder = create(:funder, :active_on_beehive => true)
      @funders << @funder
      create(:funder_attribute, :funder => @funder, :funding_stream => "All")
    end

    3.times { |i| create(:profile, :organisation => @recipient, :year => 2015-i ) }

    3.times { |i| @recipient.unlock_funder!(@funders[i]) }
  end

  test "no eligibility badge if questions remaining" do
    eligible_badge

    3.times do |i|
      @restrictions << create(:restriction)
      @funding_stream = create(:funding_stream, :restrictions => @restrictions, :funders => [@funders[i]])
    end

    2.times do |i|
      @eligibility = create(:eligibility, :recipient => @recipient, :restriction => @restrictions[i])
    end

    create_and_auth_user!(:organisation => @recipient)
    visit funders_path

    assert page.has_content?('Eligible', count: 2)
    assert page.has_content?('Not eligible', count: 0)
  end

  test "eligible badge if recipient eligible" do
    eligible_badge

    3.times do |i|
      @restrictions << create(:restriction)
      @funding_stream = create(:funding_stream, :restrictions => @restrictions, :funders => [@funders[i]])
      @eligibility = create(:eligibility, :recipient => @recipient, :restriction => @restrictions[i])
    end

    create_and_auth_user!(:organisation => @recipient)
    visit funders_path

    assert page.has_content?('Eligible', count: 3)
    assert page.has_content?('Not eligible', count: 0)
  end

  test "not eligible badge if recipient no eligible" do
    eligible_badge

    3.times do |i|
      @restrictions << create(:restriction)
      @funding_stream = create(:funding_stream, :restrictions => @restrictions, :funders => [@funders[i]])
      @eligibility = create(:eligibility, :eligible => false, :recipient => @recipient, :restriction => @restrictions[i])
    end

    create_and_auth_user!(:organisation => @recipient)
    visit funders_path

    assert page.has_content?('Eligible', count: 0)
    assert page.has_content?('Not eligible', count: 3)
  end

  test 'Welcome modal shows when user first sees funders index' do
    create_and_auth_user!(:organisation => @recipient)
    visit funders_path
    assert page.has_css?("#welcome")
  end

  test 'Welcome modal hidden if cookie present' do
    create_and_auth_user!(:organisation => @recipient)
    create_cookie('_BHwelcomeClose', true)
    visit funders_path
    assert_not page.has_css?("#welcome")
  end

  # test 'Welcome model hidden from second sign in' do
  #   create_and_auth_user!(:organisation => @recipient)
  #   @recipient.users.first.increment!(:sign_in_count)
  #   visit funders_path
  #   assert_not page.has_css?("#welcome")
  # end

  test 'Recommendation modal shows when profile for current year is completed' do
    create(:profile, :organisation => @recipient, :year => Date.today.year)
    create_and_auth_user!(:organisation => @recipient)
    visit funders_path

    # Welcome modal not shown
    assert_not page.has_css?("#welcome")
    # Recommendation modal shown
    assert page.has_css?("#recommendation")
  end

  test 'Recommendation modal hidden if cookie present' do
    create(:profile, :organisation => @recipient, :year => Date.today.year)
    create_and_auth_user!(:organisation => @recipient)
    create_cookie('_BHrecommendationClose', true)
    visit funders_path
    assert_not page.has_css?("#recommendation")
  end

  test 'Recommendation modal hidden if funder have been unlocked' do
    create(:profile, :organisation => @recipient, :year => Date.today.year)
    @funder = create(:funder)
    @recipient.unlock_funder!(@funder)
    create_and_auth_user!(:organisation => @recipient)
    visit logout_path
    create_and_auth_user!(:organisation => @recipient, :user_email => 'user2@email.com')
    visit funders_path
    assert_not page.has_css?("#recommendation")
  end

end

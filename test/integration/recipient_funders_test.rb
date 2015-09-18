require 'test_helper'

class RecipientFundersTest < ActionDispatch::IntegrationTest

  setup do
    @recipient = create(:recipient)
  end

  test 'funders are locked for recipients with no profiles' do
    3.times do |i|
      @funder = create(:funder, :active_on_beehive => true)
      create(:funder_attribute, :funder => @funder, :funding_stream => "All")
      @restrictions = Array.new(3) { |i| create(:restriction) }
      @funding_stream = create(:funding_stream, :restrictions => @restrictions, :funders => [@funder])
    end

    create_and_auth_user!(:organisation => @recipient)
    visit funders_path
    assert_not page.has_content?("Check eligibility")
    assert_equal all(".funder").length, 3
  end

  test 'recipients only needs to create one profile to unlock funders' do
    # refactor - method?
    @funders = Array.new(3) { |i| create(:funder, :active_on_beehive => true) }
    @grants = Array.new(3) { |i| create(:grants, :funder => @funders[i], :recipient => @recipient) }
    @attributes = Array.new(3) { |i| create(:funder_attribute, :funder => @funders[i]) }
    @restrictions = Array.new(3) { |i| create(:restriction) }
    @funding_streams = Array.new(3) { |i| create(:funding_stream, :restrictions => @restrictions, :funders => [@funders[i]]) }

    create(:profile, :organisation => @recipient, :year => Date.today.year )
    create_and_auth_user!(:organisation => @recipient)

    visit recipient_comparison_path(@funders[0])
    assert page.has_link?('Check eligibility (3 left)')
    find_link('Check eligibility (3 left)').click

    visit recipient_comparison_path(@funders[1])
    assert page.has_link?('Check eligibility (2 left)')
    find_link('Check eligibility (2 left)').click
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

    create(:profile, :organisation => @recipient, :year => Date.today.year, :state => 'complete')

    3.times { |i| @recipient.unlock_funder!(@funders[i]) }
  end

  def recommend_all_funders
    Recommendation.all.each { |r| r.update_column(:score, Recipient::RECOMMENDATION_THRESHOLD)}
  end

  test 'no eligibility badge if questions remaining' do
    eligible_badge

    3.times do |i|
      @restrictions << create(:restriction)
      @funding_stream = create(:funding_stream, :restrictions => @restrictions, :funders => [@funders[i]])
    end

    2.times do |i|
      @eligibility = create(:eligibility, :recipient => @recipient, :restriction => @restrictions[i])
    end

    create_and_auth_user!(:organisation => @recipient)
    recommend_all_funders
    visit funders_path

    assert page.has_content?('Eligible', count: 2)
    assert page.has_content?('Not eligible', count: 0)
  end

  test 'eligible badge if recipient eligible' do
    eligible_badge

    3.times do |i|
      @restrictions << create(:restriction)
      @funding_stream = create(:funding_stream, :restrictions => @restrictions, :funders => [@funders[i]])
      @eligibility = create(:eligibility, :recipient => @recipient, :restriction => @restrictions[i])
    end

    create_and_auth_user!(:organisation => @recipient)
    recommend_all_funders
    visit funders_path

    assert page.has_content?('Eligible', count: 3)
    assert page.has_content?('Not eligible', count: 0)
  end

  test 'not eligible badge if recipient no eligible' do
    eligible_badge

    3.times do |i|
      @restrictions << create(:restriction)
      @funding_stream = create(:funding_stream, :restrictions => @restrictions, :funders => [@funders[i]])
      @eligibility = create(:eligibility, :eligible => false, :recipient => @recipient, :restriction => @restrictions[i])
    end

    create_and_auth_user!(:organisation => @recipient)
    recommend_all_funders
    visit funders_path

    assert page.has_content?('Eligible', count: 0)
    assert page.has_content?('Not eligible', count: 3)
  end

  test 'Welcome modal shows if no profile' do
    create_and_auth_user!(:organisation => @recipient)
    visit funders_path
    assert_equal 0, @recipient.profiles.count
    assert page.has_css?("#welcome")
  end

end

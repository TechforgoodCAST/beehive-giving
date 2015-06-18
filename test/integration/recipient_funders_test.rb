require 'test_helper'

class RecipientFundersTest < ActionDispatch::IntegrationTest

  setup do
    @recipient = create(:recipient)
  end

  # test 'who is @recipient on funders' do
  # end

  test 'funders are locked for user with no profiles' do
    3.times do |i|
      @funder = create(:funder, :active_on_beehive => true)
      create(:funder_attribute, :funder => @funder, :funding_stream => "All")
    end

    create_and_auth_user!(:organisation => @recipient)
    visit '/funders'
    assert page.has_content?("See how you compare")
    assert_equal all(".uk-icon-lock").length, 3
  end

  test 'that clicking the comparison link takes you a page with options to unlock' do
    @funder = create(:funder, :active_on_beehive => true)
    create(:funder_attribute, :funder => @funder, :funding_stream => "All")
    create_and_auth_user!(:organisation => @recipient)
    visit '/funders'
    find_link('See how you compare').click
    assert page.has_link?('Complete Profile')
  end

  test 'that clicking the comparison link with a profile gives an unlock button' do
    @recipient = create(:recipient)
    @funder = create(:funder, :active_on_beehive => true)
    create(:funder_attribute, :funder => @funder, :funding_stream => "All")
    @profile = create(:profile, :organisation => @recipient)
    create_and_auth_user!(:organisation => @recipient)
    visit '/funders'
    find_link('See how you compare').click
    assert page.has_link?('Unlock Funder')
  end

  test 'recipient with 4 profiles can only pay' do
    @recipient = create(:recipient, founded_on: "01/01/2005")
    @funders   = []
    5.times do |i|
      @funder = create(:funder, :active_on_beehive => true)
      @funders << @funder
      create(:funder_attribute, :funder => @funder, :funding_stream => "All")
    end
    4.times { |i| create(:profile, :organisation => @recipient, :year => 2015-i ) }
    @funders.each_with_index { |funder, i| @recipient.unlock_funder!(@funders[i]) }

    create_and_auth_user!(:organisation => @recipient)
    visit '/funders'
    Capybara.match = :first
    find_link('See how you compare').click

    assert_not page.has_link?('Complete Profile')
    assert_not page.has_link?('Unlock Funder')
  end

  test "recipient can unlock a funder" do
    @funder = create(:funder, :active_on_beehive => true)
    create(:funder_attribute, :funder => @funder, :funding_stream => "All")
    @profile = create(:profile, :organisation => @recipient)
    create_and_auth_user!(:organisation => @recipient)
    visit '/funders'
    find_link('See how you compare').click
    assert_equal "/comparison/#{@funder.slug}/gateway", current_path
    find_link('Unlock Funder').click
    assert_equal "/comparison/#{@funder.slug}", current_path
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
    visit '/funders'

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
    visit '/funders'

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
    visit '/funders'

    assert page.has_content?('Eligible', count: 0)
    assert page.has_content?('Not eligible', count: 3)
  end

end

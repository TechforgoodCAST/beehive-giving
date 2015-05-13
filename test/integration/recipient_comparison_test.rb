require 'test_helper'

class RecipientComparisonTest < ActionDispatch::IntegrationTest

  setup do
    @recipient = create(:recipient, :founded_on => '2005/01/01')
    @funder = create(:funder)
    @recipient.unlock_funder!(@funder)
  end

  test 'All funder attributes shown if grants and profile data held' do
    @grants = 4.times { create(:grants, :funder => @funder, :recipient => @recipient) }
    @profiles = 4.times { |i| create(:profile, :organisation => @recipient, :year => 2015-i ) }
    @attribute1 = create(:funder_attribute, :funder => @funder, :funded_average_age => 4, :funded_average_income => 1234, :funded_average_paid_staff => 4)
    @attribute2 = create(:funder_attribute, :funder => @funder, :funding_stream => 'Main')
    create_and_auth_user!(:organisation => @recipient)
    visit "/comparison/#{@funder.slug}"

    assert_not page.has_content?("Oh snap")
    assert page.has_css?('.uk-alert-warning', count: 1)
    # Test chart
  end

  test 'Only overview attributes shown if grants data held' do
    @grants = 4.times { create(:grants, :funder => @funder, :recipient => @recipient) }
    @attribute1 = create(:funder_attribute, :funder => @funder)
    @attribute2 = create(:funder_attribute, :funder => @funder, :funding_stream => 'Main')
    create_and_auth_user!(:organisation => @recipient)
    visit "/comparison/#{@funder.slug}"

    assert_not page.has_content?("Oh snap")
    assert page.has_css?('.uk-alert-warning', count: 3) # recipient age also shows
    # Test chart
  end

  test 'Clicking funding stream shows relevant FunderAttribute' do
    @grants = 4.times { create(:grants, :funder => @funder, :recipient => @recipient) }
    @profiles = 4.times { |i| create(:profile, :organisation => @recipient, :year => 2015-i ) }
    @attribute1 = create(:funder_attribute, :funder => @funder, :funding_stream => 'All')
    @attribute2 = create(:funder_attribute, :funder => @funder, :funding_stream => 'Main')
    create_and_auth_user!(:organisation => @recipient)
    visit "/comparison/#{@funder.slug}"

    assert page.has_content?("4")
    click_link('Main')
    assert page.has_content?("3")
  end

  test 'Open data symbol shows if grants data held' do
    @grants = 4.times { create(:grants, :funder => @funder, :recipient => @recipient) }
    @profiles = 4.times { |i| create(:profile, :organisation => @recipient, :year => 2015-i ) }
    @attribute = create(:funder_attribute, :funder => @funder)
    create_and_auth_user!(:organisation => @recipient)
    visit "/comparison/#{@funder.slug}"

    assert page.has_css?('.uk-icon-pie-chart', count: 6)
  end

  test 'Open data symbol hidden if no grants data held' do
    @attribute = create(:funder_attribute, :funder => @funder)
    create_and_auth_user!(:organisation => @recipient)
    visit "/comparison/#{@funder.slug}"

    assert_not page.has_css?('.uk-icon-pie-chart')
  end

  test 'Data request if no funder attribute' do
    create_and_auth_user!(:organisation => @recipient)
    visit "/comparison/#{@funder.slug}"

    assert page.has_content?("Request", count: 8)
  end

  test 'Data request if no grants data held' do
    @attribute = create(:funder_attribute_no_grants, :funder => @funder)
    create_and_auth_user!(:organisation => @recipient)
    visit "/comparison/#{@funder.slug}"

    assert page.has_content?("Request", count: 8)
  end

  test 'Data requested locked if requested' do
    @attribute1 = create(:funder_attribute_no_grants, :funder => @funder)
    @attribute2 = create(:funder_attribute, :funder => @funder, :funding_stream => 'Main')
    create_and_auth_user!(:organisation => @recipient)
    visit "/comparison/#{@funder.slug}"

    page.first('a', text: "Request").click
    assert page.has_content?("Requested", count: 1)
    assert page.has_content?("Request", count: 7)
  end

  test 'Data progress if minimum not profiles held' do
    @profiles = 2.times { |i| create(:profile, :organisation => @recipient, :year => 2015-i ) }
    @grants = 4.times { create(:grants, :funder => @funder, :recipient => @recipient) }
    @attribute1 = create(:funder_attribute, :funder => @funder)
    @attribute2 = create(:funder_attribute, :funder => @funder, :funding_stream => 'Main')
    create_and_auth_user!(:organisation => @recipient)
    visit "/comparison/#{@funder.slug}"

    assert page.has_content?("Whoa!", count: 3) # recipient age also shows
  end

  test 'Recipients current Profile data shown' do
    @profiles = 4.times { |i| create(:profile, :organisation => @recipient, :year => 2015-i ) }
    create_and_auth_user!(:organisation => @recipient)
    visit "/comparison/#{@funder.slug}"

    assert page.has_css?('.stat-normal.yellow', count: 3)
  end

  # test 'Beneficairy chart hidden if minimum profiles not held' do
  # end

end

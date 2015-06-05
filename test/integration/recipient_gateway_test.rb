require 'test_helper'

class RecipientGatewayTest < ActionDispatch::IntegrationTest

  setup do
    @funder1 = create(:funder, name: "funder1")
    @funder2 = create(:funder, name: "funder2")
    @funder3 = create(:funder, name: "funder3")
    @funder4 = create(:funder, name: "funder4")
    @funder5 = create(:funder, name: "funder5")
  end

  test "recipient founded_on > 4 years ago has to create 4 profiles to unlock funders" do
    @recipient = create(:recipient, :founded_on => "#{Date.today.year-10}/01/01")
    create_and_auth_user!(:organisation => @recipient)
    create(:feedback, :user => @recipient.users.first)

    visit "/comparison/#{@funder1.slug}"
    assert_equal "/comparison/#{@funder1.slug}/gateway", current_path

    create(:profile, :organisation => @recipient, :year => Date.today.year )
    visit "/comparison/#{@funder1.slug}/gateway"
    click_link('Unlock Funder (4 left)')
    assert_equal "/comparison/#{@funder1.slug}", current_path

    create(:profile, :organisation => @recipient, :year => (Date.today.year - 1) )
    visit "/comparison/#{@funder2.slug}/gateway"
    click_link('Unlock Funder (3 left)')
    assert_equal "/comparison/#{@funder2.slug}", current_path

    create(:profile, :organisation => @recipient, :year => (Date.today.year - 2) )
    visit "/comparison/#{@funder3.slug}/gateway"
    click_link('Unlock Funder (2 left)')
    assert_equal "/comparison/#{@funder3.slug}", current_path

    create(:profile, :organisation => @recipient, :year => (Date.today.year - 3) )
    visit "/comparison/#{@funder4.slug}/gateway"
    click_link('Unlock Funder (1 left)')
    assert_equal "/comparison/#{@funder4.slug}", current_path

    visit "/comparison/#{@funder5.slug}/gateway"
    assert page.has_content?("You can only unlock 4 funders at the moment...")
  end

  test "recipient founded_on < 4 years ago has to create as many profiles as long as they have existed" do
    @recipient = create(:recipient, :founded_on => "#{Date.today.year-1}/01/01")
    create_and_auth_user!(:organisation => @recipient)
    create(:feedback, :user => @recipient.users.first)

    create(:profile, :organisation => @recipient, :year => Date.today.year )
    visit "/comparison/#{@funder1.slug}/gateway"
    click_link('Unlock Funder (4 left)')
    assert_equal "/comparison/#{@funder1.slug}", current_path

    create(:profile, :organisation => @recipient, :year => (Date.today.year - 1) )
    visit "/comparison/#{@funder2.slug}/gateway"
    click_link('Unlock Funder (3 left)')
    assert_equal "/comparison/#{@funder2.slug}", current_path

    visit "/comparison/#{@funder3.slug}/gateway"
    assert page.has_content?("Unlock Funder (2 left)")
    click_link('Unlock Funder')
    assert_equal "/comparison/#{@funder3.slug}", current_path

    visit "/comparison/#{@funder4.slug}/gateway"
    assert page.has_content?("Unlock Funder (1 left)")
    click_link('Unlock Funder')
    assert_equal "/comparison/#{@funder4.slug}", current_path

    visit "/comparison/#{@funder5.slug}/gateway"
    assert page.has_content?("You can only unlock 4 funders at the moment...")
  end

end

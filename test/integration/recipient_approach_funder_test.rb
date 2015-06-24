require 'test_helper'

class RecipientApproachFunderTest < ActionDispatch::IntegrationTest

  setup do
    @recipient = create(:recipient)
    @funder = create(:funder)
    @recipient.unlock_funder!(@funder)
    @restriction = create(:restriction)
    @funding_stream = create(:funding_stream, :restrictions => [@restriction], :funders => [@funder], :label => 'All')
    @funder_attribute = create(:funder_attribute, :funder => @funder, :funding_stream => 'All')
    create_and_auth_user!(:organisation => @recipient)
  end

  test "approach funder choice visible if eligible on comparison page" do
    @eligibility = create(:eligibility, :recipient => @recipient, :restriction => @restriction)
    visit "/comparison/#{@funder.slug}"
    assert page.has_content?("Approach for funding")
  end

  test "approach funder choice invisible if ineligible on comparison page" do
    visit "/comparison/#{@funder.slug}"
    assert_not page.has_content?("Approach for funding")
  end

  # test "recipient has to complete recommendation feedback if suggested funder" do
  #   # JS testing?
  #   @eligibility = create(:eligibility, :recipient => @recipient, :restriction => @restriction)
  #   visit "/comparison/#{@funder.slug}"
  #   Capybara.match = :first
  #   click_link("Approach for funding")
  #   assert_equal "/comparison/#{@funder.slug}/feedback", current_path
  # end

  # test "recipient does not have to complete recommendation feedback if already completed" do
  #   # JS testing?
  #   @eligibility = create(:eligibility, :recipient => @recipient, :restriction => @restriction)
  #   visit "/comparison/#{@funder.slug}"
  #   Capybara.match = :first
  #   click_link("Approach for funding")
  #   assert_equal "/comparison/#{@funder.slug}", current_path
  # end

  # test "clicking approach funder link increments counter" do
  #   # JS testing?
  # end

end
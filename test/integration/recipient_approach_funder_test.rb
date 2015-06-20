require 'test_helper'

class RecipientApproachFunderTest < ActionDispatch::IntegrationTest

  setup do
    @recipient = create(:recipient)
    @funder = create(:funder)
    @recipient.unlock_funder!(@funder)
    @restriction = create(:restriction)
    @funding_stream = create(:funding_stream, :restrictions => [@restriction], :funders => [@funder])
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

  # JS testing
  # test "clickling approach funder link increments counter" do
  #   @eligibility = create(:eligibility, :recipient => @recipient, :restriction => @restriction)
  #   visit "/comparison/#{@funder.slug}"
  #   assert_equal 0, @recipient.enquiries.count
  #   click_link("Approach for funding")
  #   assert_equal 1, @recipient.enquiries.count
  #   assert_equal 1, @recipient.enquiries.first.approach_funder_count
  #   visit "/comparison/#{@funder.slug}"
  #   click_link("Approach for funding")
  #   assert_equal 2, @recipient.enquiries.first.approach_funder_count
  # end
  #
  # test "clicking guidance link increments counter" do
  #
  # end
  #
  # test "clicking apply link increments counter" do
  #
  # end

  test "recipient has to complete suggestion feedback if suggested funder" do

  end

  test "recipient does not have to complete suggestion feedback if already completed" do

  end

  test "recipient redirected to iframe if funder not recommended" do

  end

  # funder attributes
  # + guidance link string
  # + application link string
  # + application details string/text?
  # + soft restrictions text
  # enquiry
  # + approach_funder_count

  # clicks approach funder
  # modal? with rectangles for each fundng stream with eligibility, suggestion highlighted, , soft restrictions expand?,
  # click apply link?
  # if suggested check suggestion quality
  # link to funder website in blank tab

  # test "approach funder redirects to new enquiry path" do
  #   @eligibility = create(:eligibility, :recipient => @recipient, :restriction => @restriction)
  #   visit "/comparison/#{@funder.slug}"
  #   click_link("Approach for funding")
  #   assert_equal "/funders/#{@funder.slug}/enquiries/new", current_path
  # end

end

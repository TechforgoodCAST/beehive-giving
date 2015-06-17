require "test_helper"

class RecipientFeedbackTest < ActionDispatch::IntegrationTest

  setup do
    @recipient = create(:recipient)
    @funder = create(:funder)
  end

  test "recipient with no feedback can see link" do
    create_and_auth_user!(:organisation => @recipient)
    visit "/funders"
    assert page.has_content?("Feedback", count: 2)
  end

  test "no feedback button on new feedback action" do
    create_and_auth_user!(:organisation => @recipient)
    visit '/funders'
    assert page.has_content?("Feedback", count: 2)
    visit '/feedback/new'
    assert_not page.has_content?("Feedback", count: 2)
  end

  test "recipient with feedback cannot see link" do
    create_and_auth_user!(:organisation => @recipient)
    create(:feedback, user: @recipient.users.first)
    visit "/funders"
    assert page.has_content?("Feedback", count: 0)
  end

  test "no feedback prompt before second sign in" do
    create_and_auth_user!(:organisation => @recipient)
    visit '/'
    assert_not page.has_css?(".feedback-prompt")
  end

  test "feedback prompt after second sign in" do
    create_and_auth_user!(:organisation => @recipient)
    assert_equal @recipient.users.first.sign_in_count, 0
    expire_cookies

    visit '/welcome'
    within("ul > li:nth-child(2)") do
      click_link("Sign in")
    end

    within("#sign-in") do
      fill_in("email", :with => @user.user_email)
      fill_in("password", :with => @user.password)
    end
    click_button("Sign in")
    assert_equal @recipient.users.first.sign_in_count, 1

    assert page.has_css?(".feedback-prompt")
  end

  test "feedback prompt before second funder unlock" do
    @recipient.founded_on = "01/01/2005"
    @funders, @funding_streams = [], []

    3.times do |i|
      @funder = create(:funder, :active_on_beehive => true)
      @funders << @funder
      create(:funder_attribute, :funder => @funder, :funding_stream => "All")
    end

    3.times do |i|
      @restriction1 = create(:restriction)
      @restriction2 = create(:restriction)

      @funding_stream = create(:funding_stream, :restrictions => [@restriction1, @restriction2], :funders => [@funders[i]])
      @funding_streams << @funding_stream
    end

    @profiles = 3.times { |i| create(:profile, :organisation => @recipient, :year => 2015-i) }

    create_and_auth_user!(:organisation => @recipient)

    @recipient.unlock_funder!(@funders[0])
    visit "/comparison/#{@funders[0].slug}"
    assert_equal "/comparison/#{@funders[0].slug}", current_path

    # navigating to funder page redirects
    visit '/funders'
    Capybara.match = :first
    click_link('See how you compare (Locked)')
    assert_equal "/feedback/new", current_path

    # visiting funder pages redirects if no feedback before second unlock
    visit "/comparison/#{@funders[2].slug}/gateway"
    assert_equal "/feedback/new", current_path
    visit "/comparison/#{@funders[1].slug}/gateway"
    assert_equal "/feedback/new", current_path

    # completing feedback form redirects to funder gateway
    within("#new_feedback") do
      select("10 - Extremely likely", :from => "feedback_nps")
      select("10 - Very dissatisfied", :from => "feedback_taken_away")
      select("10 - Strongly agree", :from => "feedback_informs_decision")
    end
    click_button("Submit feedback")
    assert_equal "/comparison/#{@funders[1].slug}/gateway", current_path

    # feedback only required for second unlock
    visit "/comparison/#{@funders[2].slug}/gateway"
    assert_equal "/comparison/#{@funders[2].slug}/gateway", current_path
  end

  # # Selenium testing
  # test "recipient with no feedback can submit feedback" do
  #   # Capybara.current_driver = :selenium
  #
  #   @feedback = nil
  #
  #   # visit "/welcome"
  #   create_and_auth_user!(:organisation => @recipient)
  #   # within("ul > li:nth-child(2)") do
  #   #   click_link("Sign in")
  #   # end
  #   # within("#sign-in") do
  #   #   fill_in("email", :with => @user.user_email)
  #   #   fill_in("password", :with => @user.password)
  #   # end
  #   # click_button("Sign in")
  #
  #   visit "/funders"
  #   click_link("Feedback")
  #   within("#new_feedback") do
  #     select("10 - Extremely likely", :from => "feedback_nps")
  #     select("10 - Very dissatisfied", :from => "feedback_taken_away")
  #     select("10 - Strongly agree", :from => "feedback_informs_decision")
  #   end
  #   click_button("Submit feedback")
  #
  #   assert_not page.has_content?("Feedback")
  # end

  # test "recipient with feedback cannot submit feedback" do
  # end

end

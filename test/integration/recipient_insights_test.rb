require 'test_helper'

class RecipientInsightsTest < ActionDispatch::IntegrationTest

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

  # test 'approved on hidden if all grants on 1st of jan' do
  # end

  # test 'funder attributes with no grants are not displayed' do
  # end

end

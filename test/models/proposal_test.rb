require 'test_helper'

class ProposalTest < ActiveSupport::TestCase

  setup do
    @recipient = create(:recipient)
    @proposal = build(:proposal, recipient: @recipient)
  end

  test 'a proposal belongs to a recipient' do
    assert_equal 'ACME', @proposal.recipient.name
  end

  test 'a valid proposal' do
    assert @proposal.valid?
  end

  test 'invalid proposal' do
    @proposal.funding_duration = -1
    @proposal.save
    assert_not @proposal.valid?
  end

  test 'total costs calculated' do
    @proposal.save
    assert_equal 4000, Proposal.last.total_costs
  end

  test 'minimum of one outcome required' do
    @proposal.outcome1 = nil
    @proposal.save
    assert_not @proposal.valid?
  end

  test 'creating a proposal generates recommendations' do
    funder = create(:funder)
    create(:recommendation, funder: funder, recipient: @recipient)
    create(:funder_attribute, funder: funder)
    3.times { |grant| create(:grant, funder: funder, amount_awarded: 4000) }
    @proposal.save
    recommendation = Recommendation.last
    assert_equal 1, recommendation.grant_amount_recommendation
    assert_equal recommendation.grant_amount_recommendation + recommendation.grant_duration_recommendation + recommendation.score, recommendation.total_recommendation
  end

end

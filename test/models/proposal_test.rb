require 'test_helper'

class ProposalTest < ActiveSupport::TestCase

  setup do
    @recipient = create(:recipient)
    @initial_proposal = build(:initial_proposal, recipient: @recipient)
  end

  test 'a proposal belongs to a recipient' do
    assert_equal 'ACME', @initial_proposal.recipient.name
  end

  test 'a recipient can have many proposals' do
    create(:proposal, recipient: @recipient)
    create(:initial_proposal, recipient: @recipient)
    assert_equal 2, @recipient.proposals.count
  end

  test 'cannot create second proposal until first proposal is complete' do
    @initial_proposal.save
    incomplete_proposal2 = build(:initial_proposal, recipient: @recipient)
    assert_not incomplete_proposal2.valid?
  end

  test 'a valid initial proposal' do
    assert_equal 'initial', @initial_proposal.state
    assert @initial_proposal.valid?
  end

  test 'invalid initial proposal' do
    @initial_proposal.funding_duration = -1
    @initial_proposal.save
    assert_not @initial_proposal.valid?
  end

  test 'proposal default state is initial' do
    assert_equal 'initial', @initial_proposal.state
  end

  test 'inital transitions to registered' do
    @initial_proposal.save
    @initial_proposal.next_step!
    assert_equal 'registered', @initial_proposal.state
  end

  test 'inital registered to complete' do
    @initial_proposal.save
    @initial_proposal.next_step!
    @initial_proposal.next_step!
    assert_equal 'complete', @initial_proposal.state
  end

  test 'beneficiaries other if beneficiaries other required' do
    @initial_proposal.beneficiaries_other_required = true
    assert_not @initial_proposal.valid?
  end

  test 'must affect people or other' do
    @initial_proposal.affect_people = false
    assert_not @initial_proposal.valid?
  end

  test 'gender required if affects people' do
    @initial_proposal.gender = nil
    assert_not @initial_proposal.valid?
  end

  test 'age groups required if affects people' do
    @initial_proposal.age_groups = []
    assert_not @initial_proposal.valid?
  end

  test 'gender and age_groups not required if affects other' do
    Beneficiary.destroy_all
    @initial_proposal = build(:beneficiary_other_profile, organisation: @recipient, state: 'beneficiaries', affect_people: false, affect_other: true)
    @initial_proposal.gender = nil
    @initial_proposal.age_groups = []
    assert_equal 'Other', Beneficiary.pluck(:category).uniq[0]
    assert @initial_proposal.valid?
  end

  test 'beneficiaries required if affects people' do
    @initial_proposal.beneficiaries = []
    assert_not @initial_proposal.valid?
  end

  test 'beneficiary other options required if affects other' do
    @initial_proposal.affect_people = false
    @initial_proposal.affect_other = true
    assert_equal 'People', Beneficiary.pluck(:category).uniq[0]
    assert_not @initial_proposal.valid?
  end

  test 'all age groups selected if all ages selected' do
    @initial_proposal.age_groups = [AgeGroup.first]
    @initial_proposal.save
    assert_equal AgeGroup.all.pluck(:label), @initial_proposal.age_groups.pluck(:label)
  end

  test 'a district belongs to a country' do
    assert @initial_proposal.districts.first.country
  end

  def setup_beneficiaries
    Beneficiary.last.update_attribute(:category, 'Other')
    @people_ids = Beneficiary.where(category: 'People').pluck(:id)
    @other_groups_ids = Beneficiary.where(category: 'Other').pluck(:id)
    @initial_proposal.beneficiary_ids = Beneficiary.pluck(:id)
    @initial_proposal.save
  end

  test 'beneficiary people cleared if no affect_people' do
    setup_beneficiaries
    assert_equal @people_ids, @initial_proposal.beneficiary_ids
  end

  test 'beneficiary other groups cleared if no affect_other' do
    @initial_proposal.affect_people = false
    @initial_proposal.affect_other = true
    setup_beneficiaries
    assert_equal @other_groups_ids, @initial_proposal.beneficiary_ids
  end

  test 'no beneficiaries cleared if affect both people and other' do
    @initial_proposal.affect_other = true
    setup_beneficiaries
    assert_equal Beneficiary.pluck(:id), @initial_proposal.beneficiary_ids
  end

  test 'no districts required if affect_geo is at country level' do
    @initial_proposal.affect_geo = 0
    @initial_proposal.districts = []
    assert_not @initial_proposal.valid?

    @initial_proposal.affect_geo = 1
    assert_not @initial_proposal.valid?

    @initial_proposal.affect_geo = 2
    assert @initial_proposal.valid?

    @initial_proposal.affect_geo = 3
    assert @initial_proposal.valid?
  end

  test 'districts populated by country selection if no districts required' do
    create(:district, country: Country.first)
    @initial_proposal.affect_geo = 2
    country_districts = District.where(country_id: @initial_proposal.countries.first.id).pluck(:id)
    @initial_proposal.save
    proposal_districts = @initial_proposal.districts.pluck(:id)

    assert_equal country_districts.count, (country_districts & proposal_districts).count
  end

  test 'fields for registered and compelted proposal' do
    skip
  end

  test 'total costs calculated for complete proposal' do
    skip
    @proposal.save
    assert_equal 4000, Proposal.last.total_costs
  end

  test 'minimum of one outcome required for complete proposal' do
    skip
    @proposal.outcome1 = nil
    @proposal.save
    assert_not @proposal.valid?
  end

  test 'creating a proposal generates recommendations' do
    skip
    funder = create(:funder)
    create(:recommendation, funder: funder, recipient: @recipient)
    create(:funder_attribute, funder: funder)
    3.times { |grant| create(:grant, funder: funder, amount_awarded: 4000) }
    @initial_proposal.save
    recommendation = Recommendation.last
    assert_equal 1, recommendation.grant_amount_recommendation
    assert_equal recommendation.grant_amount_recommendation + recommendation.grant_duration_recommendation + recommendation.score, recommendation.total_recommendation
  end

end

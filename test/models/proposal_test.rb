require 'test_helper'

class ProposalTest < ActiveSupport::TestCase

  setup do
    @recipient = create(:recipient)
    @initial_proposal = build(:initial_proposal, recipient: @recipient)
    @registered_proposal = build(:registered_proposal, recipient: @recipient)
    @proposal = build(:proposal, recipient: @recipient)
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

  test 'valid initial proposal' do
    assert_equal 'initial', @initial_proposal.state
    assert @initial_proposal.valid?
  end

  test 'invalid initial proposal' do
    @initial_proposal.funding_duration = -1
    @initial_proposal.save
    assert_not @initial_proposal.valid?
  end

  test 'valid registered proposal' do
    assert_equal 'registered', @registered_proposal.state
    @registered_proposal.valid?
  end

  test 'invalid registered proposal' do
    @registered_proposal.title = nil
    @registered_proposal.funding_duration = nil
    assert_not @registered_proposal.valid?
  end

  test 'valid complete proposal' do
    assert_equal 'complete', @proposal.state
    @proposal.valid?
  end

  test 'invalid complete proposal' do
    @proposal.title = nil
    @proposal.funding_duration = nil
    assert_not @proposal.valid?
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
    @initial_proposal.affect_people = false
    @initial_proposal.affect_other = true
    @initial_proposal.gender = nil
    @initial_proposal.age_groups = []
    @initial_proposal.beneficiaries.each do |b|
      b.update_attribute(:category, 'Other')
    end

    assert @initial_proposal.valid?
  end

  test 'beneficiaries required if affects people' do
    @initial_proposal.beneficiaries = []
    assert_not @initial_proposal.valid?
  end

  test 'beneficiary other options required if affects other' do
    @initial_proposal.save
    @initial_proposal.update_attribute(:affect_people, false)
    @initial_proposal.update_attribute(:affect_other, true)
    @initial_proposal.beneficiaries.last.update_attribute(:category, 'Other')

    # beneficiary people options cleared after validation
    @initial_proposal.valid?
    assert_equal 0, @initial_proposal.beneficiaries.where(category: 'People').count

    assert_equal 1, @initial_proposal.beneficiaries.where(category: 'Other').count
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
    @initial_proposal.save
    @initial_proposal.beneficiaries.last.update_attribute(:category, 'Other')
    @people_ids = @initial_proposal.beneficiaries.where(category: 'People').pluck(:id)
    @other_groups_ids = @initial_proposal.beneficiaries.where(category: 'Other').pluck(:id)
  end

  test 'beneficiary people cleared if no affect_people' do
    setup_beneficiaries
    @initial_proposal.save

    assert_equal 'People', @initial_proposal.beneficiaries.pluck(:category)[0]
    assert_equal 'Other', @initial_proposal.beneficiaries.pluck(:category)[1]
    assert_equal @people_ids, @initial_proposal.beneficiary_ids
  end

  test 'beneficiary other groups cleared if no affect_other' do
    setup_beneficiaries
    @initial_proposal.affect_people = false
    @initial_proposal.affect_other = true
    @initial_proposal.save

    assert_equal @other_groups_ids, @initial_proposal.beneficiary_ids
  end

  test 'no beneficiaries cleared if affect both people and other' do
    setup_beneficiaries
    @initial_proposal.affect_other = true
    @initial_proposal.save

    assert_equal @people_ids + @other_groups_ids, @initial_proposal.beneficiary_ids
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

  test 'creating a proposal generates recommendations' do
    funder = create(:funder)
    create(:funder_attribute, funder: funder)

    assert_equal 0, Recommendation.count
    @initial_proposal.save
    assert_equal 1, Recommendation.count
  end

  test 'recipient cannot have duplicate proposal titles' do
    @proposal.save
    second_proposal = build(:registered_proposal, recipient: @recipient, title: @proposal.title)
    assert_not second_proposal.valid?
  end

end

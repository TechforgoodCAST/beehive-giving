require 'test_helper'

class FundTest < ActiveSupport::TestCase

  setup do
    setup_funds
    @fund = @funds.first
  end

  test 'is valid' do
    assert @fund.valid?
  end

  test 'belongs to funder' do
    assert_equal @funder.name, @fund.funder.name
  end

  test 'without funder is invalid' do
    @fund.funder = nil
    assert_not @fund.valid?
  end

  test 'has many deadlines' do
    @fund.save!
    assert_equal 2, @fund.deadlines.count
  end

  test 'deadlines not required if deadlines not limited' do
    @fund.deadlines_limited = false
    @fund.deadlines = []
    @fund.save
    assert @fund.valid?
  end

  test 'deadlines required if deadlines_known and deadlines_limited' do
    @fund.deadlines_limited = true
    @fund.deadlines = []
    @fund.save
    assert_not @fund.valid?
  end

  test 'has many stages' do
    @fund.save!
    assert_equal 2, @fund.stages.count
  end

  test 'stages required if stages_known' do
    @fund.stages = []
    @fund.save
    assert_not @fund.valid?
  end

  test 'has many funding types' do
    @fund.save!
    assert_equal FundingType::FUNDING_TYPE.count, @fund.funding_types.count
  end

  test 'amount_min_limited and amount_max_limited present if amount_known' do
    @fund.amount_min_limited = nil
    @fund.amount_max_limited = nil
    @fund.save
    assert_not @fund.valid?
  end

  test 'amount_min required if amount_min_limited' do
    @fund.amount_min = nil
    @fund.save
    assert_not @fund.valid?
  end

  test 'amount_max required if amount_max_limited' do
    @fund.amount_max = nil
    @fund.save
    assert_not @fund.valid?
  end

  test 'duration_months_min_limited and duration_months_min_limited present if duration_months_known' do
    @fund.duration_months_min_limited = nil
    @fund.duration_months_max_limited = nil
    @fund.save
    assert_not @fund.valid?
  end

  test 'duration_months_min required if duration_months_min_limited' do
    @fund.duration_months_min = nil
    @fund.save
    assert_not @fund.valid?
  end

  test 'duration_months_max required if duration_months_max_limited' do
    @fund.duration_months_max = nil
    @fund.save
    assert_not @fund.valid?
  end

  test 'accepts_calls present if accepts_calls_known' do
    @fund.accepts_calls = nil
    @fund.save
    assert_not @fund.valid?
  end

  test 'contact_number present if accepts_calls' do
    @fund.contact_number = nil
    @fund.save
    assert_not @fund.valid?
  end

  test 'geographic_scale is valid' do
    const = Proposal::AFFECT_GEO

    @fund.geographic_scale = const.first[1] - 1
    @fund.save
    assert_not @fund.valid?

    @fund.geographic_scale = const.last[1] + 1
    @fund.save
    assert_not @fund.valid?
  end

  test 'countries present if geographic_scale_limited' do
    @fund.countries = []
    @fund.save
    assert_not @fund.valid?
  end

  test 'districts present if geographic_scale_limited' do
    @fund.districts = []
    @fund.save
    assert_not @fund.valid?
  end

  test 'has many countries' do
    @fund.save
    assert_equal 2, @fund.countries.count
  end

  test 'has many districts' do
    @fund.save
    assert_equal 6, @fund.districts.count
  end

  test 'restrictions present if restrictions_known' do
    @fund.restrictions = []
    @fund.save
    assert_not @fund.valid?
  end

  test 'has many restrictions' do
    @fund.save
    assert_equal 2, @fund.restrictions.count
  end

  test 'outcomes present if outcomes_known' do
    @fund.outcomes = []
    @fund.save
    assert_not @fund.valid?
  end

  test 'has many outcomes' do
    @fund.save
    assert_equal 2, @fund.outcomes.count
  end

  test 'decision_makes present if decision_makers_known' do
    @fund.decision_makers = []
    @fund.save
    assert_not @fund.valid?
  end

  test 'has many decision_makers' do
    @fund.save
    assert_equal 2, @fund.decision_makers.count
  end

end

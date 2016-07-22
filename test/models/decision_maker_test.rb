require 'test_helper'

class DecisionMakerTest < ActiveSupport::TestCase

  setup do
    setup_funds(2, true)
    @decision_maker = @decision_makers.first
  end

  test 'is valid' do
    assert @decision_maker.valid?
  end

  test 'name is unique' do
    assert_not build(:decision_maker, name: @decision_maker.name).valid?
  end

  test 'has many funds' do
    assert_equal 2, @decision_maker.funds.count
  end

  test 'has many funders through funds' do
    @funds.last.funder = create(:funder)
    @funds.last.save
    assert_equal 2, @decision_maker.funders.count
  end

end

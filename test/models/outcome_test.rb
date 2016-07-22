require 'test_helper'

class OutcomeTest < ActiveSupport::TestCase
  setup do
    setup_funds(2, true)
    @outcome = @outcomes.first
  end

  test 'is valid' do
    assert @outcome.valid?
  end

  test 'outcome is unique' do
    assert_not build(:outcome, outcome: @outcome.outcome).valid?
  end

  test 'has many funds' do
    assert_equal 2, @outcome.funds.count
  end

  test 'has many funders through funds' do
    @funds.last.funder = create(:funder)
    @funds.last.save
    assert_equal 2, @outcome.funders.count
  end
end

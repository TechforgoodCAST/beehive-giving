require 'test_helper'

class RestrictionTest < ActiveSupport::TestCase

  setup do
    setup_funds(2, true)
    @restriction = @restrictions.first
  end

  test 'is valid' do
    assert @restriction.valid?
  end

  test 'name is unique' do
    assert_not build(:restriction, details: @restriction.details).valid?
  end

  test 'has many funds' do
    assert_equal 2, @restriction.funds.count
  end

  test 'has many funders through funds' do
    @funds.last.funder = create(:funder)
    @funds.last.save
    assert_equal 2, @restriction.funders.count
  end

end

require 'test_helper'

class CountryTest < ActiveSupport::TestCase

  setup do
    setup_funds(2, true)
    @country = @countries.first
  end

  test 'is valid' do
    assert @country.valid?
  end

  test 'name is unique' do
    assert_not build(:country, name: @country.name).valid?
  end

  test 'alpha2 is unique' do
    assert_not build(:country, alpha2: @country.alpha2).valid?
  end

  test 'has many districts' do
    assert_equal 3, @country.districts.count
  end

  test 'has many funds' do
    assert_equal 2, @country.funds.count
  end

  test 'has many funders through funds' do
    @funds.last.funder = create(:funder)
    @funds.last.save
    assert_equal 2, @country.funders.count
  end

  test 'has many proposals' do
    skip
  end

  test 'has many grants' do
    skip
  end

end

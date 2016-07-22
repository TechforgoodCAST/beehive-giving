require 'test_helper'

class DistrictTest < ActiveSupport::TestCase

  setup do
    setup_funds(2, true)
    @uk = @countries.first
    @kenya = @countries.last
    @uk_district = @uk_districts.first
  end

  test 'is valid' do
    assert @uk_district.valid?
  end

  test 'belongs to country' do
    assert_equal @uk_district, @uk.districts.first
  end

  test 'district is unique for country' do
    assert_not build(:district, country: @uk, district: @uk_district.district).valid?
    assert build(:district, country: @kenya, district: @uk_district.district).valid?
  end

  test 'has many funds' do
    assert_equal 2, @uk_district.funds.count
  end

  test 'has many funders through funds' do
    @funds.last.funder = create(:funder)
    @funds.last.save
    assert_equal 2, @uk_district.funders.count
  end

  test 'has many proposals' do
    skip
  end

  test 'has many grants' do
    skip
  end

end

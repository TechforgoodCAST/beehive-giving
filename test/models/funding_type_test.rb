require 'test_helper'

class FundingTypeTest < ActiveSupport::TestCase

  setup do
    setup_funds(2, true)
    @funding_type = @funding_types.first
  end

  test 'is valid' do
    FundingType.destroy_all
    FactoryGirl.reload
    const = FundingType::FUNDING_TYPE
    funding_types = Array.new(const.count) { |i| create(:funding_type) }
    const.each_with_index do |type, i|
      assert funding_types[i].valid?
      assert_equal type, funding_types[i].label
    end
  end

  test 'label is unique' do
    assert_not build(:funding_type, label: @funding_type.label).valid?
  end

  test 'has many funds' do
    assert_equal @funds.count, FundingType.first.funds.count
  end

  test 'has many funders through funds' do
    @funds.last.funder = create(:funder)
    @funds.last.save
    assert_equal 2, @funding_type.funders.count
  end

end

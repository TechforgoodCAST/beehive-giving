# TODO: deprecated
require 'test_helper'

class GrantTest < ActiveSupport::TestCase
  setup do
    seed_test_db
    @funder = create(:funder)
    @grant  = build(:grant, funder: @funder,
                            countries: [@countries.first],
                            districts: @uk_districts)
  end

  test 'is valid' do
    assert @grant.valid?
  end

  test 'belongs to funder' do
    assert_equal @funder, @grant.funder
  end

  test 'only positive numbers are allowed' do
    @grant.amount_awarded = -10
    assert_not @grant.valid?
  end
end

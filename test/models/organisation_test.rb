require 'test_helper'

class OrganisationTest < ActiveSupport::TestCase

  test 'has one subscription' do
    assert_equal Subscription.first, create(:recipient).subscription
  end

  test 'has many users' do
    org = create(:recipient)
    2.times { |i| org.users << create(:user) }
    assert_equal 2, org.users.count
  end

  test 'registration numbers cleared if unregistered' do
    org = create(:recipient, org_type: 0, street_address: 'London Road')
    assert_equal nil, org.charity_number
    assert_equal nil, org.company_number
  end

  test 'registration numbers cleared if other org type' do
    org = create(:recipient, org_type: 4, street_address: 'London Road')
    assert_equal nil, org.charity_number
    assert_equal nil, org.company_number
  end

  # TODO:
  # test 'search_address valid'
  # test 'financials_multiplier'
  # test 'staff_select'

end

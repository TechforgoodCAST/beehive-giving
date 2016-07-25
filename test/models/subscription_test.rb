require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase

  test 'belongs to organisation' do
    assert_equal create(:recipient), Subscription.first.organisation
  end

end

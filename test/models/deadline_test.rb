require 'test_helper'

class DeadlineTest < ActiveSupport::TestCase

  setup do
    setup_funds(1, true)
    @deadline = Deadline.first
    @fund = @funds.first
  end

  test 'is valid' do
    assert @deadline.valid?
  end

  test 'belongs to fund' do
    assert_equal @deadline, @fund.deadlines.first
  end

end

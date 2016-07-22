require 'test_helper'

class StageTest < ActiveSupport::TestCase

  setup do
    setup_funds(1, true)
    @fund = @funds.first
    @stage1 = @fund.stages[0]
    @stage2 = @fund.stages[1]
  end

  test 'is valid' do
    assert @stage1.valid?
    assert @stage2.valid?
  end

  test 'belongs to fund' do
    assert_equal @stage1, @fund.stages.first
  end

  test 'without fund is invalid' do
    @stage1.fund = nil
    @stage1.save
    assert_not @stage1.valid?
  end

  test 'has unique name' do
    @stage2.name = @stage1.name
    @stage2.save
    assert_not @stage2.valid?
  end

  test 'position must be greate than 0' do
    @stage1.position = 0
    @stage1.save
    assert_not @stage1.valid?
  end

  test 'position must be unique' do
    assert_equal 1, @stage1.position
    @stage2.position = 1
    @stage2.save
    assert_not @stage2.valid?
  end

  test 'position must be next in line' do
    assert_equal 1, @stage1.position
    @stage2.position = 3
    @stage2.save
    assert_not @stage2.valid?
  end

end

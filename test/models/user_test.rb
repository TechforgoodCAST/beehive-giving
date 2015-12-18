require 'test_helper'

class UserTest < ActiveSupport::TestCase

  setup do
    @recipient = create(:recipient)
    @user = build(:user, organisation: @recipient)
  end

  test 'a user belongs to an organisation' do
    assert_equal 'ACME', @user.organisation.name
  end

  test "doesn't allow duplicate emails for different users" do
    create(:user)
    assert_not build(:user).valid?
  end

  test 'a valid user' do
    assert @user.valid?
  end

  test 'valid name' do
    @user.update_attributes(:first_name => 'Double-barrel')
    assert @user.valid?
  end

  test 'invalid name' do
    assert_not build(:user, :first_name => ':Name!').valid?
  end

  test 'capitalize name and strip whitespace' do
    user = create(:user, :first_name => ' john ')
    assert_equal 'John', user.first_name
  end

  test 'no organisation declared validation' do
    assert_not build(:user, :job_role => "None, I don't work/volunteer for a non-profit").valid?
  end

  test 'no numbers requried if new project or other selected' do
    assert false
  end

  test 'charity number required if seeking charity' do
    assert false
  end

  test 'company number required if seeking company' do
    assert false
  end

  test 'both numbers required if seeking both' do
    assert false
  end

end

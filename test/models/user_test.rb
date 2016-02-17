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

  test 'charity and company numbers requried based on org type' do
    case @user.org_type
    when 1
      assert_not @user.valid?
      @user.charity_number = '123'
      assert @user.valid?
    when 2
      assert_not @user.valid?
      @user.company_number = '123'
      assert @user.valid?
    when 3
      assert_not @user.valid?
      @user.charity_number = '123'
      @user.company_number = '123'
      assert @user.valid?
    else
      assert_equal nil, @user.charity_number
      assert_equal nil, @user.company_number
      assert @user.valid?
    end
  end

  test 'user email is downcased' do
    @user.user_email = 'UPCASE@email.com'
    @user.save
    assert_equal 'upcase@email.com', @user.user_email
  end

end

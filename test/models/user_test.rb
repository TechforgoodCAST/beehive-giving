require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @recipient = create(:recipient)
    @user = build(:user, organisation: @recipient)
  end

  test "a user belongs to an organisation" do
    assert_equal 'ACME', @user.organisation.name
  end

  test "doesn't allow duplicate emails for different users" do
    create(:user)
    assert_not build(:user).valid?
  end

  test "a valid user" do
    assert @user.valid?
  end
end

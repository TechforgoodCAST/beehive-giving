require 'test_helper'

class GrantTest < ActiveSupport::TestCase
  setup do
    @acme = create(:acme)
    @grant = build(:grant, organisation: @acme)
  end

  test "a grant belongs to an organisation" do
    assert_equal 'ACME', @grant.organisation.name
  end

  test "a valid profile" do
    assert @grant.valid?
  end

  test "only positive numbers are allowed" do
    @grant.amount_awarded = -10
    assert_not @grant.valid?
  end
end

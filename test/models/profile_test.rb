require 'test_helper'

class ProfileTest < ActiveSupport::TestCase

  setup do
    @recipient = create(:recipient)
    @profile = build(:profile, organisation: @recipient, state: 'beneficiaries')
    @country = create(:country)
    @district = build(:district, country: @country)
  end

  test 'a profile belongs to an organisation' do
    assert_equal 'ACME', @profile.organisation.name
  end

  test 'a valid profile' do
    assert @profile.valid?
  end

  test "doesn't allow duplicates for the same org/year" do
    create(:profile, organisation: @recipient)
    assert_not @profile.valid?
  end

  test 'allows duplicate years for the different orgs' do
    @profile =  build(:profile, organisation: create(:organisation, n: 1))
    assert @profile.valid?
  end

  test 'a district belongs to a country' do
    assert @district.country
  end

  test 'profile starts with beneficiaries' do
    assert_equal 'beneficiaries', @profile.state
  end

  test 'beneficiaries transitions to location' do
    @profile.save
    @profile.next_step!
    assert_equal 'location', @profile.state
  end

  test 'location transitions to team' do
    @profile.save
    2.times { @profile.next_step! }
    assert_equal 'team', @profile.state
  end

  test 'team transitions to work' do
    @profile.save
    3.times { @profile.next_step! }
    assert_equal 'work', @profile.state
  end

  test 'work transitions to finance' do
    @profile.save
    4.times { @profile.next_step! }
    assert_equal 'finance', @profile.state
  end

  test 'finance transitions to complete' do
    @profile.save
    5.times { @profile.next_step! }
    assert_equal 'complete', @profile.state
  end

  test 'beneficiaries other if beneficiaries other required' do
    @profile.beneficiaries_other_required = true
    assert_not @profile.valid?
  end

  test 'implementors other if implementors other required' do
    @profile.implementors_other_required = true
    assert_not @profile.valid?
  end

  test 'implementations other if implementations other required' do
    @profile.implementations_other_required = true
    assert_not @profile.valid?
  end

  test 'must affect people or other' do
    @profile.affect_people = false
    assert_not @profile.valid?
  end

  test 'gender required if affects people' do
    @profile.gender = nil
    assert_not @profile.valid?
  end

  test 'age groups required if affects people' do
    @profile.age_groups = []
    assert_not @profile.valid?
  end

  test 'gender and age_groups not required if affects other' do
    Beneficiary.destroy_all
    @profile = build(:beneficiary_other_profile, organisation: @recipient, state: 'beneficiaries', affect_people: false, affect_other: true)
    @profile.gender = nil
    @profile.age_groups = []
    assert_equal 'Other', Beneficiary.pluck(:category).uniq[0]
    assert @profile.valid?
  end

  test 'beneficiaries required if affects people' do
    @profile.beneficiaries = []
    assert_not @profile.valid?
  end

  test 'beneficiary other options required if affects other' do
    @profile.affect_people = false
    @profile.affect_other = true
    assert_equal 'People', Beneficiary.pluck(:category).uniq[0]
    assert_not @profile.valid?
  end

  test 'all age groups selected if all ages selected' do
    @profile.age_groups = [AgeGroup.first]
    @profile.save
    assert_equal AgeGroup.all.pluck(:label), @profile.age_groups.pluck(:label)
  end

end

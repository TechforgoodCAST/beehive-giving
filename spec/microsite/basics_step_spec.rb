require 'rails_helper'
require 'support/match_helper'
require 'shared/reg_no_validations'
require 'shared/org_type_validations'

describe BasicsStep do
  subject do
    BasicsStep.new(
      funder_id: create(:funder).id,
      funding_type: 0, # Don't know
      total_costs: 10_000,
      org_type: ORG_TYPES[2][1], # A registered charity
      charity_number: '123456'
    )
  end

  let(:helper) { MatchHelper.new }

  before(:each) do
    helper.stub_charity_commission subject.charity_number
  end

  include_examples 'reg no validations'
  include_examples 'org_type validations'

  it '#funder_id required' do
    subject.funder_id = nil
    is_expected.not_to be_valid
  end

  context '#funding_type' do
    it 'required' do
      subject.funding_type = nil
      is_expected.not_to be_valid
    end

    it 'in list' do
      subject.funding_type = -1
      is_expected.not_to be_valid
    end
  end

  context '#total_costs' do
    it 'required' do
      subject.total_costs = nil
      is_expected.not_to be_valid
    end

    it 'is number' do
      subject.total_costs = '0'
      is_expected.not_to be_valid
    end

    it 'greater than zero' do
      subject.total_costs = 0
      is_expected.not_to be_valid
    end
  end

  context '#save' do
    before(:each) do
      Proposal.skip_callback :save, :save_all_age_groups_if_all_ages
      Proposal.skip_callback :save, :clear_age_groups_and_gender_unless_affect_people
    end

    after(:each) do
      Proposal.set_callback :save, :save_all_age_groups_if_all_ages
      Proposal.set_callback :save, :clear_age_groups_and_gender_unless_affect_people
    end

    it 'creates Recipient' do
      expect(Recipient.count).to eq 0
      subject.save
      expect(Recipient.count).to eq 1
    end

    it 'creates Proposal' do
      expect(Proposal.count).to eq 0
      subject.save
      expect(Proposal.last.state).to eq 'basics'
    end

    it 'creates Assessment' do
      expect(Assessment.count).to eq 0
      subject.save
      expect(Assessment.last.state).to eq 'eligibility'
    end
  end
end

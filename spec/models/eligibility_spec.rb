require 'rails_helper'

describe 'Eligibility' do
  before(:each) do
    @app.seed_test_db.setup_funds(num: 2).create_recipient
    @db = @app.instances
    @recipient = @db[:recipient]
    @recipient_restriction = Restriction.first
    @proposal_restriction = Restriction.last
  end

  # TODO: write
  it 'fund without org restrictions'
  it 'fund without proposal restrictions'
  it 'fund.eligibility removes fund when eligibility destroyed'

  context 'proposal' do
    before(:each) do
      @app.create_registered_proposal
      @proposal = @app.instances[:registered_proposal]
      @eligibility = create(:proposal_eligibility,
                            category: @proposal,
                            question: @proposal_restriction)
    end

    it 'with eligible as null is invalid' do
      @eligibility.eligible = nil
      expect(@eligibility).not_to be_valid
    end

    it 'belongs to recipient' do
      expect(@eligibility.category).to eq @proposal
      expect(@eligibility.category_type).to eq 'Proposal'
    end

    it 'category_type must equal Restriction category' do
      expect(@eligibility.category_type).to eq @proposal_restriction.category
      @eligibility.category_type = 'Organisation'
      expect(@eligibility).not_to be_valid
    end

    it 'is unique to proposal and restriction' do
      expect(
        build(:answer, category: @proposal,
                       question: @recipient_restriction)
      ).not_to be_valid
    end
  end

  context 'recipient' do
    before(:each) do
      @eligibility = create(:recipient_eligibility,
                            category: @recipient,
                            question: @recipient_restriction)
    end

    it 'belongs to recipient' do
      expect(@eligibility.category).to eq @recipient
      expect(@eligibility.category_type).to eq 'Organisation'
    end

    it 'category_type must equal Restriction category' do
      expect(@eligibility.category_type).to eq @recipient_restriction.category
      @eligibility.category_type = 'Proposal'
      expect(@eligibility).not_to be_valid
    end

    it 'is unique to recipient and restriction' do
      expect(
        build(:answer, category: @recipient,
                       question: @proposal_restriction)
      ).not_to be_valid
    end
  end
end

require 'rails_helper'

describe Rating::Eligibility::ProposalCategories do
  subject { Rating::Eligibility::ProposalCategories.new(1234, reasons) }

  let(:reasons) do
    {
      'reasons' => [
        {
          'id' => 'grant_funding_eligible',
          'fund_value' => [201],
          'proposal_value' => 201
        },
        {
          'id' => 'grant_funding_ineligible',
          'fund_value' => [202, 203],
          'proposal_value' => 201
        },
        {
          'id' => 'other_eligible',
          'fund_value' => [101],
          'proposal_value' => 101
        },
        {
          'id' => 'other_ineligible',
          'fund_value' => [201, 203],
          'proposal_value' => 101
        }
      ]
    }
  end

  context '#messages' do
    it 'grant_funding_eligible' do
      message = 'Provides Capital grant funding'
      expect(subject.messages).to include(message)
    end

    it 'grant_funding_ineligible' do
      message = 'Only provides Revenue - Core and Revenue - Project grant ' \
                'funding, and you are seeking Capital funding'
      expect(subject.messages).to include(message)
    end

    it 'other_eligible' do
      message = "Provides 'Other' support, contact the provider directly " \
                'for more details'
      expect(subject.messages).to include(message)
    end

    it 'other_ineligible' do
      message = 'Only provides Capital and Revenue - Project support, and ' \
                'you are seeking Other support'
      expect(subject.messages).to include(message)
    end
  end
end

require 'rails_helper'

describe Rating::Eligibility::RecipientCategories do
  subject { Rating::Eligibility::RecipientCategories.new(1234, reasons) }

  let(:reasons) do
    {
      'reasons' => [
        {
          'id' => 'eligible',
          'fund_value' => [203, 301],
          'proposal_value' => 301
        },
        {
          'id' => 'ineligible',
          'fund_value' => [203, 301],
          'proposal_value' => 302
        }
      ]
    }
  end

  context '#messages' do
    it 'eligible' do
      message = 'Provides support to A charitable organisation'
      expect(subject.messages).to include(message)
    end

    it 'ineligible' do
      message = 'Only supports the following types of recipient: ' \
                'An unregistered charity and A charitable organisation; ' \
                'you are seeking support for A company'
      expect(subject.messages).to include(message)
    end
  end
end

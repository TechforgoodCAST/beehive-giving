require 'rails_helper'

describe Rating::Eligibility::Amount do
  subject { Rating::Eligibility::Amount.new(1234, reasons) }

  let(:reasons) do
    {
      'reasons' => [
        {
          'id' => 'above_max',
          'fund_value' => '£150,000',
          'proposal_value' => '£180,000'
        },
        {
          'id' => 'below_min',
          'fund_value' => '£50,000',
          'proposal_value' => '£30,000'
        }
      ]
    }
  end

  context '#messages' do
    it 'above_max' do
      message = "The maximum amount you're seeking (£180,000) is more than " \
                'the maximum awarded (£150,000)'
      expect(subject.messages).to include(message)
    end

    it 'below_min' do
      message = "The minimum amount you're seeking (£30,000) is less than " \
                'the minimum awarded (£50,000)'
      expect(subject.messages).to include(message)
    end
  end
end

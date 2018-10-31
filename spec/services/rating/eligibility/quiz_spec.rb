require 'rails_helper'

describe Rating::Eligibility::Quiz do
  subject { Rating::Eligibility::Quiz.new(1234, reasons) }

  let(:reasons) do
    {
      'reasons' => [
        {
          'id' => 'eligible',
          'fund_value' => [1],
          'proposal_value' => { 1 => true }
        },
        {
          'id' => 'incomplete',
          'fund_value' => [1, 2],
          'proposal_value' => { 1 => true }
        },
        {
          'id' => 'ineligible',
          'fund_value' => [1],
          'proposal_value' => { 1 => false }
        }
      ]
    }
  end

  context '#messages' do
    it 'eligible' do
      message = 'You meet all of the restrictions set by this opportunity'
      expect(subject.messages).to include(message)
    end

    it 'incomplete' do
      message = 'The restrictions for this opportunity have changed, ' \
                'and your answers are incomplete'
      expect(subject.messages).to include(message)
    end

    it 'ineligible' do
      message = 'You do not meet 1 of the restrictions for this opportunity'
      expect(subject.messages).to include(message)
    end
  end

  it '#link'
  #   expect(subject.link).to eq("<a href='#1234'>View answers</a>")
  # end
end

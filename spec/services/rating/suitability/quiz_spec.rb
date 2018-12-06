require 'rails_helper'

describe Rating::Suitability::Quiz do
  subject { Rating::Suitability::Quiz.new(1234, reasons) }

  let(:reasons) do
    {
      'reasons' => [
        {
          'id' => 'eligible',
          'fund_value' => [1],
          'proposal_value' => { '1' => true }
        },
        {
          'id' => 'incomplete',
          'fund_value' => [1, 2],
          'proposal_value' => { '1' => true }
        },
        {
          'id' => 'ineligible',
          'fund_value' => [1],
          'proposal_value' => { '1' => false }
        }
      ]
    }
  end

  context '#messages' do
    it 'eligible' do
      message = 'You meet all of the priorities set by this opportunity'
      expect(subject.messages).to include(message)
    end

    it 'incomplete' do
      message = 'The priorities for this opportunity have changed, ' \
                'and your answers are incomplete'
      expect(subject.messages).to include(message)
    end

    it 'ineligible' do
      message = 'You do not meet 1 of the priorities for this opportunity'
      expect(subject.messages).to include(message)
    end
  end

  it '#link' do
    link = "<a data-remote='true' rel='nofollow' " \
           "href='/assessments/1234/answers?criteria_type=priorities'>" \
           "View answers</a>"
    expect(subject.link).to eq(link)
  end
end

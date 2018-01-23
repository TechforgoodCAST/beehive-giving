require 'rails_helper'

describe ResultsCell do
  subject { cell(:results, assessment).call(:eligibility) }
  let(:assessment) { nil }

  context 'eligibility' do
    it { is_expected.to have_text('Amount') }
    it { is_expected.to have_text('Income') }
    it { is_expected.to have_text('Location') }
    it { is_expected.to have_text('Quiz') }
    it { is_expected.to have_text('Recipient') }
  end
end

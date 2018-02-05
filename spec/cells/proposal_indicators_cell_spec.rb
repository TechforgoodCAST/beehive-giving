require 'rails_helper'

describe ProposalIndicatorsCell do
  controller ProposalsController

  subject do
    cell(:proposal_indicators, proposal).call(:eligibility_progress_bar)
  end

  let(:proposal) { build(:proposal) }

  before do
    %i[eligible incomplete ineligible].each_with_index do |assessment, i|
      create_list(assessment, (i + 1), proposal: proposal)
    end
  end

  it 'progress bars are correct width' do
    expect(subject).to have_css('.bar', count: 3)
    titles = subject.find_all('.bar').pluck('title')
    expect(titles).to include('3 funds ineligible')
    expect(titles).to include('2 funds to check')
    expect(titles).to include('1 fund eligible')
  end

end

require 'rails_helper'

describe ProposalIndicatorsCell do
  controller ProposalsController

  before(:each) do
    @app.seed_test_db.setup_funds(num: 4)
        .create_recipient.create_registered_proposal
    @proposal = Proposal.last
    @funds = Fund.all
  end

  it 'progress bars are correct width' do
    @proposal.update_column(
      :eligibility, {
        @funds[0].slug => { 'quiz' => { 'eligible' => true } },
        @funds[1].slug => { 'quiz' => { 'eligible' => false } },
        @funds[2].slug => { 'location' => { 'eligible' => true } },
        @funds[3].slug => { 'quiz' => { 'eligible' => true } },
      }
    )
    indicator = cell(:proposal_indicators, @proposal).call(:eligibility_progress_bar)
    expect(indicator).to have_css ".bar", count: 3
    titles = indicator.find_all(".bar").pluck('title')
    expect(titles).to include '1 fund ineligible'
    expect(titles).to include '2 funds eligible'
    expect(titles).to include '1 fund to check'
  end

end

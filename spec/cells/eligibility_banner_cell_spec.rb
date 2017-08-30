require 'rails_helper'

describe EligibilityBannerCell do
  controller ApplicationController

  before(:each) do
    @app.seed_test_db.setup_funds(num: 3)
        .create_recipient.create_registered_proposal
    @funds = Fund.active.all
    @proposal = Proposal.last
  end

  it 'not shown if no eligibility check' do
    banner = cell(:eligibility_banner, @proposal).call(:show)
    expect(banner.text).to eq ''
  end

  it 'shows eligible' do
    @proposal.update_column(
      :eligibility,
      @funds[0].slug => {
        'location' => { 'eligible' => true },
        'quiz' => { 'eligible' => true, 'count_failing' => 0 }
      }
    )
    banner = cell(:eligibility_banner, @proposal, fund: @funds[0]).call(:show)
    expect(banner).to have_link 'Apply for funding'
  end

  it 'shows quiz ineligible' do
    @proposal.update_column(
      :eligibility,
      @funds[0].slug => {
        'quiz' => { 'eligible' => false, 'count_failing' => 1 }
      }
    )
    banner = cell(:eligibility_banner, @proposal, fund: @funds[0]).call(:show)
    expect(banner).to have_text 'do not meet 1'
    expect(banner).not_to have_text 'location'
  end

  it 'shows location ineligible' do
    @proposal.update_column(
      :eligibility,
      @funds[0].slug => { 'location' => { 'eligible' => false } }
    )
    banner = cell(:eligibility_banner, @proposal, fund: @funds[0]).call(:show)
    expect(banner).not_to have_text 'do not meet 1'
    expect(banner).to have_text 'location'
  end

  it 'shows amount ineligible' do
    @proposal.update_column(
      :eligibility,
      @funds[0].slug => { 'amount' => { 'eligible' => false } }
    )
    banner = cell(:eligibility_banner, @proposal, fund: @funds[0]).call(:show)
    expect(banner).not_to have_text 'do not meet 1'
    expect(banner).to have_text 'amount'
  end

  it 'shows org_type ineligible' do
    @proposal.update_column(
      :eligibility,
      @funds[0].slug => { 'org_type' => { 'eligible' => false } }
    )
    banner = cell(:eligibility_banner, @proposal, fund: @funds[0]).call(:show)
    expect(banner).not_to have_text 'do not meet 1'
    expect(banner).to have_text ORG_TYPES[4][2]
  end

  it 'shows both ineligible' do
    @proposal.update_column(
      :eligibility,
      @funds[0].slug => {
        'location' => { 'eligible' => false },
        'quiz' => { 'eligible' => false, 'count_failing' => 1 }
      }
    )
    banner = cell(:eligibility_banner, @proposal, fund: @funds[0]).call(:show)
    expect(banner).to have_text 'do not meet 1'
    expect(banner).to have_text 'location'
  end
end

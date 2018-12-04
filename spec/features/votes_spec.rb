require 'rails_helper'

feature 'Votes' do
  let(:assessment) { build(:assessment) }
  let(:proposal) { create(:proposal, assessments: [assessment]) }

  before do
    visit report_path(proposal)
    click_link('Vote')
  end

  scenario 'can vote on assessment', js: true do
    submit_vote
    expect(current_path).to eq(report_path(proposal))
    expect(current_url).to include("#assessment-#{assessment.id}")
    expect(page).to have_text('1 agree')
  end

  scenario 'can cancel vote' do
    click_link('Cancel')
    expect(current_path).to eq(report_path(proposal))
  end

  scenario 'specify relationship if another role', js: true do
    submit_vote(role: 'Another role', relationship: 'Expert')
    expect(current_path).to eq(report_path(proposal))
  end

  scenario 'reason if disagree', js: true do
    submit_vote(agree: 'No', reason: 'Some reason...')
    expect(current_path).to eq(report_path(proposal))
    expect(page).to have_text('1 disagree')
  end

  def submit_vote(role: 'I created the report', relationship: nil, agree: 'Yes', reason: nil)
    select(role)
    fill_in(:vote_relationship_details, with: relationship) if relationship
    select(agree)
    fill_in(:vote_reason, with: reason) if reason
    click_button('Vote')
  end
end

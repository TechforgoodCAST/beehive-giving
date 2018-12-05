require 'rails_helper'

feature 'Answers' do
  let(:fund) { create(:fund_with_rules) }
  let(:proposal) { create(:proposal) }

  before do
    fund.restrictions.where(category: 'Proposal').each_with_index do |c, i|
      create(:answer, criterion: c, category: proposal, eligible: i.odd?)
    end
    Assessment.analyse_and_update!(Fund.active, proposal)
    visit report_path(proposal)
  end

  scenario 'assessment not found' do
    visit answers_path('missing')
    expect(page).to have_text('Not found')
  end

  scenario 'criteria_type param not provided' do
    visit answers_path(Assessment.last, criteria_type: 'missing')
    expect(page).to have_text('Not found')
  end

  scenario 'restrictions displayed', js: true do
    find_all('a', text: 'View answers')[0].click
    restriction = fund.restrictions.where(category: 'Proposal').last
    expect(page).to have_text(restriction.details)
  end

  scenario 'priorities displayed', js: true do
    find_all('a', text: 'View answers')[1].click
    priority = fund.priorities.where(category: 'Proposal').last
    expect(page).to have_text(priority.details)
  end

  scenario 'can close modal window', js: true do
    click_link('View answers', match: :first)
    expect(page).to have_css('body.js-open-modal')
    find('.js-close-modal').click
    click_link('Opportunities', match: :first)
    expect(current_path).to eq(opportunities_path)
    expect(page).not_to have_css('body.js-open-modal')
  end

  scenario 'do not meet criteria message', js: true do
    click_link('View answers', match: :first)
    expect(page).to have_text('You do not meet this criteria', count: 1)
  end
end

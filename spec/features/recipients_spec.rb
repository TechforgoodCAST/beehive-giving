require 'rails_helper'

feature 'Recipients' do
  include ShowMeTheCookies

  # TODO: before(:all)?
  before do
    create(:district)
    @funder = create(:funder_with_funds)
    @theme = Theme.first
    visit new_recipient_path(@theme)
  end

  scenario 'create individual', js: true do
    select('An individual')
    select_location
    click_button('Next')

    expect(current_path).to eq(new_proposal_path)
  end

  scenario 'create unincorporated organisation', js: true do
    select('A community or voluntary group')
    complete_form_as_organisation
    select_location
    click_button('Next')

    expect(current_path).to eq(new_proposal_path)
  end

  scenario 'create incorporated organisation', js: true do
    select('A charitable organisation')
    fill_in(:recipient_description, with: 'Exempt charity')
    complete_form_as_organisation
    select_location
    click_button('Next')

    expect(current_path).to eq(new_proposal_path)
  end

  scenario 'assigned to user when signed in', js: true do
    user = create(:user)
    create_cookie(:auth_token, user.auth_token)
    visit new_recipient_path(@theme)

    select('An individual')
    select_location
    click_button('Next')

    expect(user.recipients.count).to eq(1)
  end
end

def select_location
  within('.recipient_country') do
    find('.choices').click
    find('#choices-recipient_country_id-item-choice-2').click
  end

  within('.recipient_district') do
    find('.choices').click
    find('#choices-recipient_district_id-item-choice-1').click
  end
end

def complete_form_as_organisation
  fill_in(:recipient_name, with: 'Established community charity')
  select('Less than £10k')
  select('4 years or more')
end

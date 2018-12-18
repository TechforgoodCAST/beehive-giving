require 'rails_helper'

feature 'Recipients' do
  include SignInHelper

  before(:each) do
    create(:district)
    @funder = create(:funder_with_funds)
    @theme = Theme.first
  end

  let(:recipient) { Recipient.last }

  scenario 'missing collection' do
    visit new_recipient_path('missing')
    expect(page.status_code).to eq(404)
    expect(page).to have_text('Not found')
  end

  context 'funder collection' do
    let(:collection) { @funder }

    before { visit new_recipient_path(collection) }

    scenario 'create individual', js: true do
      select('An individual')
      select_location
      choose_answers(to: 3)
      click_button('Next')

      expect(current_path).to eq(new_proposal_path(collection, recipient))
    end

    scenario 'create unincorporated organisation', js: true do
      select('A community or voluntary group')
      complete_form_as_organisation
      select_location
      choose_answers(to: 3)
      click_button('Next')

      expect(current_path).to eq(new_proposal_path(collection, recipient))
    end
  end

  context 'theme collection' do
    let(:collection) { @theme }

    before { visit new_recipient_path(collection) }

    scenario 'create incorporated organisation', js: true do
      select('A charitable organisation')
      fill_in(:recipient_description, with: 'Exempt charity')
      complete_form_as_organisation
      select_location
      choose_answers(to: 1)
      click_button('Next')

      expect(current_path).to eq(new_proposal_path(collection, recipient))
    end

    scenario 'assigned to user when signed in', js: true do
      user = create(:user_with_password)
      sign_in(user)
      visit new_recipient_path(collection)

      select('An individual')
      select_location
      choose_answers(to: 1)
      click_button('Next')

      expect(user.recipients.count).to eq(1)
    end

    scenario 'eligible labels inverted' do
      collection.restrictions.where(category: 'Recipient')
                .last.update(invert: true)
      visit new_recipient_path(collection)

      eligible_labels = (0..1).map do |i|
        find("label[for=recipient_answers_attributes_#{i}_eligible_true]").text
      end

      expect(eligible_labels.count('No')).to eq(1)
      expect(eligible_labels.count('Yes')).to eq(1)
    end
  end

  def choose_answers(from: 0, to: 0)
    (from..to).each do |i|
      find("label[for='recipient_answers_attributes_#{i}_eligible_true']").click
    end
  end

  def complete_form_as_organisation
    fill_in(:recipient_name, with: 'Established community charity')
    select('Less than £10k')
    select('4 years or more')
  end

  def eligible_answer_label_text(index)
    find("label[for=recipient_answers_attributes_#{index}_eligible_true]").text
  end

  def select_location
    within('.recipient_country') do
      find('.choices').click
      find('#choices-recipient_country_id-item-choice-2').click
    end

    within('.recipient_district') do
      find('.choices').click
      assert_selector('#choices-recipient_district_id-item-choice-1')
      find('#choices-recipient_district_id-item-choice-1').click
    end
  end
end

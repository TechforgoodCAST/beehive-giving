require 'rails_helper'

feature 'Proposals' do
  before do
    @funder = create(:funder_with_funds)
    @theme = Theme.first

    @recipient = create(:recipient)
    @country = @recipient.country
    create(:district, country: @country)
    @districts = @country.districts.order(:id)
  end

  let(:collection) { @funder }

  scenario 'create other support proposal', js: true do
    visit new_proposal_path(collection, @recipient)

    fill_in_summary

    select('Other')
    fill_in(:proposal_support_details, with: 'Accelerator')

    select('An entire country')
    select_country
    choose_answers(from: 0, to: 7)
    fill_in_user_fields
    check(:proposal_public_consent)
    click_button('Get suitability report')

    expect(current_path).to eq(new_charge_path(Proposal.last))
  end

  scenario 'create funding proposal', js: true do
    visit new_proposal_path(collection, @recipient)
    valid_funding_request

    expect(current_path).to eq(new_charge_path(Proposal.last))
  end

  scenario 'create local proposal', js: true do
    visit new_proposal_path(collection, @recipient)

    fill_in_summary
    fill_in_funding_details

    select('One or more local areas')
    select_country
    select_districts

    choose_answers(from: 0, to: 7)
    fill_in_user_fields
    check(:proposal_public_consent)
    click_button('Get suitability report')

    expect(Proposal.last.countries).to contain_exactly(@country)
    expect(Proposal.last.districts).to eq(@districts)
  end

  scenario 'create regional proposal', js: true do
    visit new_proposal_path(collection, @recipient)

    fill_in_summary
    fill_in_funding_details

    select('One or more regions')
    select_country
    select_districts

    choose_answers(from: 0, to: 7)
    fill_in_user_fields
    check(:proposal_public_consent)
    click_button('Get suitability report')

    expect(Proposal.last.countries).to contain_exactly(@country)
    expect(Proposal.last.districts).to eq(@districts)
  end

  scenario 'create national proposal', js: true do
    visit new_proposal_path(collection, @recipient)

    fill_in_summary
    fill_in_funding_details

    select('An entire country')
    select_country

    choose_answers(from: 0, to: 7)
    fill_in_user_fields
    check(:proposal_public_consent)
    click_button('Get suitability report')

    expect(Proposal.last.countries).to contain_exactly(@country)
  end

  scenario 'create international proposal', js: true do
    create(:country)
    visit new_proposal_path(collection, @recipient)

    fill_in_summary
    fill_in_funding_details

    select('Across many countries')
    select_countries

    choose_answers(from: 0, to: 7)
    fill_in_user_fields
    check(:proposal_public_consent)
    click_button('Get suitability report')

    expect(Proposal.last.countries.size).to eq(2)
  end

  scenario 'creation triggers email', js: true do
    ActionMailer::Base.deliveries = []
    visit new_proposal_path(collection, @recipient)
    valid_funding_request

    proposal = Proposal.last
    subject = "Funder report ##{proposal.id} for #{collection.name} [Beehive]"

    expect(ActionMailer::Base.deliveries.size).to eq(1)
    expect(ActionMailer::Base.deliveries.last.subject).to eq(subject)
  end

  scenario 'missing collection' do
    visit new_proposal_path('missing', 'missing')
    expect(page.status_code).to eq(404)
    expect(page).to have_text('Not found')
  end

  scenario 'associated to collection', js: true do
    visit new_proposal_path(collection, @recipient)
    valid_funding_request

    expect(Proposal.last.collection).to eq(collection)
  end

  scenario 'missing recipient' do
    visit new_proposal_path(collection, 'missing')
    expect(page.status_code).to eq(404)
    expect(page).to have_text('Not found')
  end

  scenario 'existing proposal associated to recipient' do
    create(:proposal, recipient: @recipient)
    visit new_proposal_path(collection, @recipient)
    expect(current_path).to eq(report_path(@recipient.proposal))
  end

  scenario 'creates new user', js: true do
    visit new_proposal_path(collection, @recipient)
    valid_funding_request

    expect(User.count).to eq(1)
  end

  scenario 'assignes to existing user'

  scenario 'user details hidden when signed in'

  scenario 'restriction labels inverted'

  scenario 'priority labels inverted'

  scenario 'creates assessments'

  def choose_answers(from: 0, to: 0)
    (from..to).each do |i|
      choose("proposal_answers_attributes_#{i}_eligible_true")
    end
  end

  def fill_in_funding_details
    select('Revenue - Core')
    fill_in(:proposal_min_amount, with: 10_000)
    fill_in(:proposal_max_amount, with: 250_000)
    fill_in(:proposal_min_duration, with: 3)
    fill_in(:proposal_max_duration, with: 36)
  end

  def fill_in_summary
    fill_in(:proposal_title, with: 'Community space')
    fill_in(:proposal_description, with: 'A new roof for our community centre.')

    within('.proposal_themes') do
      find('.choices').click
      find('#choices-proposal_theme_ids-item-choice-1').click
      find('#choices-proposal_theme_ids-item-choice-2').click
    end
  end

  def fill_in_user_fields
    fill_in(:proposal_user_attributes_first_name, with: 'John')
    fill_in(:proposal_user_attributes_last_name, with: 'Doe')
    fill_in(:proposal_user_attributes_email, with: 'email@ngo.org')
    fill_in(:proposal_user_attributes_email_confirmation, with: 'email@ngo.org')
    check(:proposal_user_attributes_terms_agreed)
    choose(:proposal_user_attributes_marketing_consent_true)
  end

  def select_country
    within('.proposal_country_id') do
      find('.choices').click
      find('#choices-proposal_country_id-item-choice-2').click
    end
  end

  def select_countries
    within('.proposal_countries') do
      find('.choices').click
      find('#choices-proposal_country_ids-item-choice-2').click
      find('#choices-proposal_country_ids-item-choice-3').click
      find('.hint').click
    end
  end

  def select_districts
    within('.proposal_districts') do
      find('.choices').click
      find('#choices-proposal_district_ids-item-choice-1').click
      find('#choices-proposal_district_ids-item-choice-2').click
      find('.hint').click
    end
  end

  def valid_funding_request
    fill_in_summary
    fill_in_funding_details
    select('An entire country')
    select_country
    choose_answers(from: 0, to: 7)
    fill_in_user_fields
    check(:proposal_public_consent)
    click_button('Get suitability report')
  end
end

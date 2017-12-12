require 'rails_helper'
require_relative '../support/match_helper'
require_relative '../support/microsite_helper'

feature 'Microsite' do
  let(:helper) { MatchHelper.new }
  let(:user) { MicrositeHelper.new }

  before(:each) do
    helper.stub_charity_commission '123456'
    Proposal.skip_callback :save, :save_all_age_groups_if_all_ages
    Proposal.skip_callback :save, :clear_age_groups_and_gender_unless_affect_people
  end

  after(:each) do
    Proposal.set_callback :save, :save_all_age_groups_if_all_ages
    Proposal.set_callback :save, :clear_age_groups_and_gender_unless_affect_people
  end

  scenario 'invalid route parameters' do
    [
      microsite_basics_path('invalid'),
      microsite_eligibility_path('invalid'),
      microsite_eligibility_path('invalid', double('Assessment', id: 1))
    ].each do |path|
      visit path
      expect(current_path).to eq root_path
    end
  end

  context 'integration' do
    before(:each) do
      create(:country, name: 'United Kingdom', alpha2: 'GB')
      @funder = create(:funder)
    end

    scenario 'new assessment' do
      visit microsite_basics_path(@funder)
      user.submit_basics_step

      assessment = Assessment.last
      expect(current_path).to eq microsite_eligibility_path(@funder, assessment)

      # TODO: no eligibility questions
      user.submit_eligibility_step
      expect(current_path).to eq microsite_pre_results_path(@funder, assessment)

      user.submit_pre_results
      expect(current_path).to eq microsite_results_path(@funder, assessment)
      expect(ActionMailer::Base.deliveries.last.subject)
        .to eq "[Results] Should you apply to #{@funder.name}?"
    end

    scenario 'signed in' do
      @app.with_user.sign_in
      visit microsite_basics_path @funder
      expect(current_path).to eq microsite_basics_path(@funder)
    end

    scenario 'existing recipient' do
      visit microsite_basics_path(@funder)
      user.submit_basics_step

      existing_recipient = Recipient.last

      visit microsite_basics_path(@funder)
      user.submit_basics_step

      expect(Assessment.last.recipient).to eq existing_recipient
    end

    scenario 'only find existing recipient with valid reg numbers' do
      Recipient.new(org_type: 'Another type of organisation')
               .save(validate: false)

      expect(Recipient.count).to eq 1

      visit microsite_basics_path(@funder)
      user.submit_basics_step(
        org_type: 'Another type of organisation',
        charity_number: nil
      )

      expect(Recipient.count).to eq 2
    end

    scenario 'assessment per funder' do
      funder2 = create(:funder)

      visit microsite_basics_path(@funder)
      user.submit_basics_step

      visit microsite_basics_path(funder2)
      user.submit_basics_step

      expect(@funder.assessments.size).to eq 1
      expect(funder2.assessments.size).to eq 1
    end

    scenario 'new assessment and proposal per unique request' do
      visit microsite_basics_path(@funder)
      user.submit_basics_step

      visit microsite_basics_path(@funder)
      user.submit_basics_step total_costs: 12_345

      expect(Recipient.last.assessments.size).to eq 2
    end

    scenario 'no assessment redirects to basics path' do
      visit microsite_results_path(@funder, 'missing')
      expect(current_path).to eq microsite_basics_path(@funder)
    end

    context 'existing assessment' do
      let(:assessment) do
        Country.destroy_all
        @app.seed_test_db
            .create_recipient
            .create_registered_proposal
            .setup_funds

        Assessment.create!(
          recipient: Recipient.last,
          proposal: Proposal.last,
          funder: @funder
        )
      end

      scenario 'redirects to correct path' do
        {
          'eligibility' => microsite_eligibility_path(@funder, assessment),
          'pre_results' => microsite_pre_results_path(@funder, assessment),
          'results'     => microsite_results_path(@funder, assessment)
        }.each do |state, path|
          assessment.update_column(:state, state)
          visit microsite_results_path(@funder, assessment)
          expect(current_path).to eq path
        end
      end

      context 'results' do
        scenario 'valid token grants access' do
          assessment.update(state: 'results', access_token: 'secret')
          visit microsite_results_path(@funder, assessment, t: assessment.access_token)
          expect(current_path).to eq microsite_results_path(@funder, assessment)
        end

        scenario 'invalid token denies access' do
          visit microsite_results_path(@funder, 1)
          expect(current_path).to eq microsite_basics_path(@funder)
        end
      end
    end
  end
end

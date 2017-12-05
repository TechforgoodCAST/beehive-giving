require 'rails_helper'

describe EligibilityCell do
  controller ApplicationController

  before(:each) do
    @app.seed_test_db.setup_funds(num: 3)
        .create_recipient.create_registered_proposal
    @fund = Fund.active.last
    @proposal = Proposal.last
  end

  context 'fund page' do
    it 'shows eligible' do
      @proposal.update_column(
        :eligibility,
        @fund.slug => {
          'location' => { 'eligible' => true },
          'quiz' => { 'eligible' => true, 'count_failing' => 0 }
        }
      )
      eligibility = cell(:eligibility, @proposal, fund: @fund).call(:analysis)
      expect(eligibility).to have_text 'Eligible'
    end

    it 'shows ineligible' do
      @proposal.update_column(
        :eligibility,
        @fund.slug => {
          'location' => { 'eligible' => false },
          'quiz' => { 'eligible' => true, 'count_failing' => 0 }
        }
      )
      eligibility = cell(:eligibility, @proposal, fund: @fund).call(:analysis)
      expect(eligibility).to have_text 'Ineligible'
    end

    it 'shows incomplete' do
      eligibility = cell(:eligibility, @proposal, fund: @fund).call(:analysis)
      expect(eligibility).to have_text 'Incomplete'
    end

    it 'shows all criteria' do
      eligibility = cell(:eligibility, @proposal, fund: @fund).call(:analysis)
      expect(eligibility).to have_css '.perc66', count: 6
    end
  end

  context 'fund card' do
    it 'shows eligible' do
      @proposal.update_column(
        :eligibility,
        @fund.slug => {
          'location' => { 'eligible' => true },
          'quiz' => { 'eligible' => true, 'count_failing' => 0 }
        }
      )
      eligibility = cell(:eligibility, @proposal, fund: @fund).call(:card)
      expect(eligibility).to have_text 'Eligible'
    end

    it 'shows ineligible' do
      @proposal.update_column(
        :eligibility,
        @fund.slug => {
          'location' => { 'eligible' => false },
          'quiz' => { 'eligible' => true, 'count_failing' => 0 }
        }
      )
      eligibility = cell(:eligibility, @proposal, fund: @fund).call(:card)
      expect(eligibility).to have_text 'Ineligible'
    end

    it 'shows incomplete' do
      eligibility = cell(:eligibility, @proposal, fund: @fund).call(:card)
      expect(eligibility).to have_text 'Incomplete'
    end

    it 'shows all criteria' do
      eligibility = cell(:eligibility, @proposal, fund: @fund).call(:card)
      expect(eligibility).to have_css 'li', count: 6
    end

    it 'shows correct ineligible criteria' do
      @proposal.update_column(
        :eligibility,
        @fund.slug => {
          'location' => { 'eligible' => false },
          'quiz' => { 'eligible' => true, 'count_failing' => 0 }
        }
      )
      eligibility = cell(:eligibility, @proposal, fund: @fund).call(:card)
      expect(eligibility).to have_css 'li span.bg-red', count: 1
    end
  end

  context 'funds actions' do
    it 'shows eligible' do
      @proposal.update_column(
        :eligibility,
        @fund.slug => {
          'location' => { 'eligible' => true },
          'quiz' => { 'eligible' => true, 'count_failing' => 0 }
        }
      )
      eligibility = cell(:eligibility, @proposal, fund: @fund).call(:index)
      expect(eligibility).to have_text 'Eligible'
    end

    it 'shows ineligible' do
      @proposal.update_column(
        :eligibility,
        @fund.slug => {
          'location' => { 'eligible' => false },
          'quiz' => { 'eligible' => true, 'count_failing' => 0 }
        }
      )
      eligibility = cell(:eligibility, @proposal, fund: @fund).call(:index)
      expect(eligibility).to have_text 'Ineligible'
    end

    it 'shows incomplete' do
      eligibility = cell(:eligibility, @proposal, fund: @fund).call(:index)
      expect(eligibility).to have_text 'Eligibility'
    end
  end
end

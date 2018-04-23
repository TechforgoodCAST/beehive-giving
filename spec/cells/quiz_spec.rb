require 'rails_helper'
# include ActionView::Helpers::FormHelper
# include ActionView::Helpers::FormOptionsHelper
# include SimpleForm::ActionViewExtensions::FormHelper

describe QuizCell do
  # controller ApplicationController

  # before(:each) do
  #   @app.seed_test_db.setup_funds(num: 3)
  #       .create_recipient.create_proposal
  #   @fund = Fund.active.first
  #   @proposal = Proposal.last
  # end

  context '#no-proposal' do
    # before(:each) do
    #   @proposal = nil
    # end

    it 'no button is shown'
    #   quiz = cell(:quiz, @fund, proposal: @proposal).call(:show)
    #   expect(quiz).not_to have_tag 'button.uk-button'
    # end

    it 'no radio buttons are shown'
  end

  it 'all restrictions shown'

  it 'all eligibilities are shown correctly'

  it 'button is shown'
  #   quiz = cell(:quiz, @fund, proposal: @proposal).call(:show)
  #   expect(quiz).to have_tag 'button.uk-button'
  # end

  it 'button shows correctly if fund is checked'
  #   @proposal.eligiblities[@fund.slug] = {"quiz": {"eligible": true}}
  #   quiz = cell(:quiz, @fund, proposal: @proposal).call(:show)
  #   expect(quiz).to have_tag 'button.uk-button'
  #   expect(quiz).to have_text 'Update'
  # end

  it 'button shows correctly if subscribed'
  #   @proposal.recipient.subscribe!
  #   quiz = cell(:quiz, @fund, proposal: @proposal).call(:show)
  #   expect(quiz).to have_tag 'button.uk-button'
  #   expect(quiz).to have_text 'Check eligibility'
  # end

  it 'restriction label is correct'
end

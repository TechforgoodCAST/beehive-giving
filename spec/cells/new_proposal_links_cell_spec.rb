require 'rails_helper'

describe NewProposalLinksCell do
  controller ProposalsController

  before(:each) do
    @app.seed_test_db.create_recipient.with_user.create_registered_proposal
    @db = @app.instances
    @recipient = @db[:recipient]
    @proposal = @db[:registered_proposal]
  end

  it 'incomplete shows edit link' do
    incomplete = cell(:new_proposal_links, @proposal).call(:show)
    expect_change_proposal(incomplete)
    expect(incomplete)
      .to have_link 'New proposal',
                    href: edit_signup_proposal_path(@proposal)
  end

  it 'complete and subscribed shows new link' do
    @proposal.next_step!
    @recipient.subscribe!
    complete_subscribed = cell(:new_proposal_links, @proposal).call(:show)
    expect_change_proposal(complete_subscribed)
    expect(complete_subscribed)
      .to have_link 'New proposal',
                    href: new_recipient_proposal_path(@recipient)
  end

  it 'complete and unsubscribed shows why hidden' do
    @proposal.next_step!
    complete_unsubscribed = cell(:new_proposal_links, @proposal).call(:show)
    expect_change_proposal(complete_unsubscribed)
    expect(complete_unsubscribed)
      .to have_link 'New proposal', href: '#why-hidden'
  end

  private

    def expect_change_proposal(proposal)
      expect(proposal).to have_link 'Change proposal',
                                    href: recipient_proposals_path(@recipient)
    end
end

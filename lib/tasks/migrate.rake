namespace :migrate do
  # usage: rake migrate:recipient RECIPIENT=<id>
  desc 'Migrate legacy recipient and associations'
  task recipient: :environment do
    migrate(ENV['ORG'])
  end

  # usage: rake migrate:recipients RECIPIENTS=<id>..<id>
  desc 'Migrate legacy recipients and associations'
  task recipients: :environment do
    Range.new(*ENV['RECIPIENTS'].split('..')).each { |id| migrate(id) }
  end

  def migrate(id)
    recipient = Recipient.find_by(id: id)

    return puts "No Recipient #{id}" unless recipient

    print "Recipient #{id}"

    proposals = Proposal.where(recipient_id: recipient.id)
    users = User.where(organisation_id: recipient.id)

    funds = if recipient.subscription.active?
              Fund.active
            elsif recipient.reveals.any?
              Fund.where(slug: recipient.reveals).active
            end

    return puts ': no Users' unless users.any?

    users.each_with_index do |user, index|
      if index > 0
        # TODO: avoid uncessesary dups
        print "[Duplicating] Recipient #{id}"

        new_recipient = recipient.dup
        new_recipient.slug = new_recipient.generate_slug(
          new_recipient, new_recipient.slug
        )
        new_recipient.save(validate: false)

        print "->#{new_recipient.id}"

        new_proposals = proposals.map do |proposal|
          new_proposal = proposal.dup
          new_proposal.recipient = new_recipient
          new_proposal.save(validate: false)
          proposal
        end

        updates(user, new_recipient, new_proposals, funds)
      else
        updates(user, recipient, proposals, funds)
      end
    end
  end

  def updates(user, recipient, proposals, funds)
    recipient.update_column(:user_id, user.id)

    return puts ': no Proposals' unless proposals.any?

    proposals.each do |proposal|
      if funds.nil?
        funds = Fund.joins(:themes).active.merge(proposal.themes).distinct
      end

      proposal.user_id = user.id
      proposal.generate_token(:access_token)
      proposal.save(validate: false)

      if proposal.prevent_funder_verification?
        proposal.update_column(:private, proposal.updated_at)
      end

      proposal.assessments.destroy_all
      Assessment.analyse_and_update!(funds, proposal)
    end

    puts ": Proposal #{recipient.proposal.id}, User #{user.id}"
  end
end

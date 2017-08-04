namespace :proposals do
  # usage: rake proposals:migrate_themes! SAVE=true
  desc 'Update specified funds'
  task migrate_themes!: :environment do
    Proposal.skip_callback(:save, :after, :initial_recommendation)

    Proposal.joins(:beneficiaries).distinct.find_each do |proposal|
      proposal.themes = Theme.where(
        name: proposal.beneficiaries.map { |b| SignupProposal::MAPPING[b.label] }
      )
      proposal.save!(validate: false) if ENV['SAVE']
      print '.'
    end
    puts "\n"
  end
end

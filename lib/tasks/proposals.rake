namespace :proposals do
  # usage: rake proposals:migrate_themes! MAPPING=/path/to/file.json SAVE=true
  # MAPPING JSON format: { <Beneficiary.name>: <Theme.name>, ... }
  desc 'Update specified funds'
  task migrate_themes!: :environment do
    mapping = open(ENV['MAPPING']) { |file| JSON.parse(file.read) }

    Proposal.skip_callback(:save, :after, :initial_recommendation)

    Proposal.joins(:beneficiaries).distinct.find_each do |proposal|
      proposal.themes = Theme.where(
        name: proposal.beneficiaries.map { |b| mapping[b.label] }
      )
      proposal.save!(validate: false) if ENV['SAVE']
      print '.'
    end
    puts "\n"
  end
end

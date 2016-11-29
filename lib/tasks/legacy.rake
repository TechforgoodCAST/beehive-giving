namespace :legacy do
  desc 'Update missing proposal gender'
  task update_gender: :environment do
    Proposal.where(gender: '').each do |proposal|
      proposal.update_attribute(:gender, 'All genders')
    end
  end

  desc 'Update incomplete recipients'
  task update_recipient: :environment do
    Recipient.joins(:proposals).where('
      operating_for IS NULL OR
      income IS NULL OR
      employees IS NULL OR
      volunteers IS NULL
    ').distinct.each_with_index do |recipient, i|
      puts "#{i+1}: #{recipient.get_charity_data} #{recipient.get_company_data} #{recipient.save}"
    end
  end

  desc 'Update legacy recommendations'
  task update_recommendations: :environment do
    Dotenv.load
    Recipient.joins(:proposals, :recommendations)
      .where('recommendations.fund_id IS NULL')
      .where('
        operating_for IS NOT NULL AND
        income IS NOT NULL AND
        employees IS NOT NULL AND
        volunteers IS NOT NULL
      ')
      .distinct
      .each_with_index do |recipient, i|
        recipient.recommendations.destroy_all
        recipient.proposals.each do |proposal|
          puts "#{i+1}: #{recipient.id}: #{proposal.id}"
          proposal.initial_recommendation
        end
    end
  end
end

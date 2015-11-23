namespace :update do

  # usage: be rake update:funder_attributes
  desc 'Update funder attribute insights'
  task :funder_attributes => :environment do
    FunderAttribute.where(funding_stream: 'All').find_each { |f| f.set_insights }
  end

  # usage: be rake update:eligibility
  desc 'Ensure legacy users have eligibility set on recommendations'
  task :eligibility => :environment do
    Recipient.joins(:users).find_each { |r| r.check_eligibilities }
  end

end

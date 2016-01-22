namespace :counters do

  # usage: be rake counters:unlocks
  desc 'Reset counter caches for funder unlocks'
  task :unlocks => :environment do
    Recipient.joins(:recipient_funder_accesses).find_each { |r| Recipient.reset_counters(r.id, :recipient_funder_accesses) }
  end

  # usage: be rake counters:grants
  desc 'Reset counter caches for recipient grants'
  task :grants => :environment do
    Recipient.joins(:grants).find_each { |r| Recipient.reset_counters(r.id, :grants) }
  end
    
end

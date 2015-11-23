namespace :funder_attributes do
  desc 'Update funder attribute insights'

  # usage: be rake funder_attributes:update
  task :update => :environment do
    FunderAttribute.where(funding_stream: 'All').find_each { |f| f.set_insights }
  end

end

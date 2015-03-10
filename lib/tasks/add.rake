# usage: RAILS_ENV=production FILE=filename.csv be rake import:add, add SAVE=true to actually save it.
namespace :import do
  desc "Import grants data from file"
  task :add => :environment do
    require 'csv'

    @filename = ENV['FILE']

    CSV.foreach(@filename, :headers => true) do |row|
      funder = Funder.where(:name => row['funder']).first
      recipient = Recipient.where(:name => row['recipient']).first

      values = {
        :funder => funder,
        :recipient => recipient,
        :funding_stream => row['funding_stream'],
        :grant_type => row['grant_type'],
        :attention_how => row['attention_how'],
        :amount_awarded => row['amount_awarded'],
        :amount_applied => row['amount_applied'],
        :installments => row['installments'],
        :approved_on => row['approved_on'],
        :start_on => row['start_on'],
        :end_on => row['end_on'],
        :attention_on => row['attention_on'],
        :applied_on => row['applied_on']
      }

      Grant.create(values)
    end
  end
end

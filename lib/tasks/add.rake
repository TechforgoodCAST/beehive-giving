# usage: RAILS_ENV=production FILE=filename.csv be rake import:add
# add: SKIP_VALIDATION=true to skip validations
# add: SAVE=true to actually save

namespace :import do
  desc "Import grants data from file"
  task :add => :environment do

    require 'csv'

    @messages = []
    @filename = ENV['FILE']
    @skip_validation = ENV['SKIP_VALIDATION']

    CSV.foreach(@filename, :headers => true, encoding:'iso-8859-1:utf-8') do |row|
      @find_funder = Funder.where(:name => row['funder']).first

      recipient_values = {
        :name => row['recipient'],
        :contact_number => row['contact_number'],
        :street_address => row['street_address'],
        :city => row['city'],
        :region => row['region'],
        :postal_code => row['postal_code'],
        :country => row['country'],
        :website => row['website'],
        :charity_number => row['charity_number'],
        :company_number => row['company_number'],
        :mission => row['mission'],
        :status => row['status'],
        :registered => row['registered'],
        :founded_on => row['founded_on'],
        :registered_on => row['registered_on']
      }

      recipient = Recipient.new(recipient_values)
      recipient.skip_validation = @skip_validation

      if ENV['SAVE']
        if recipient.valid?
          recipient.save
        else
          @messages << "\n#{recipient.name}"
          @messages << "Recipient: #{recipient.errors.messages}"
        end
      end

      @find_recipient = Recipient.where(:name => row['recipient']).first

      grant_values = {
        :funder => @find_funder,
        :recipient => @find_recipient,
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

      grant = Grant.new(grant_values)
      grant.skip_validation = @skip_validation

      if ENV['SAVE']
        if grant.valid?
          grant.save
        else
          @messages << "\n#{recipient.name}"
          @messages << "Grant: #{grant.errors.messages}"
        end
      end

    end

    puts @messages

  end
end

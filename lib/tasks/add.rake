# usage: RAILS_ENV=production FILE=filename.csv be rake import:add
# add: SKIP_VALIDATION=true to skip validations
# add: SAVE=true to actually save

namespace :import do
  desc "Import grants data from file"
  task :add => :environment do

    require 'open-uri'
    require 'csv'

    @messages = []
    @filename = ENV['FILE']
    @skip_validation = ENV['SKIP_VALIDATION']

    recipient_count = 0
    grant_count = 0

    CSV.parse(open(@filename).read, :headers => true, encoding:'iso-8859-1:utf-8') do |row|
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

      recipient = Recipient.find_or_initialize_by(recipient_values)
      recipient.skip_validation = @skip_validation

      if recipient.valid?
        recipient.save if ENV['SAVE']
        recipient_count += 1
      else
        @messages << "\n#{recipient.name}"
        @messages << "Recipient: #{recipient.errors.messages}"
      end

      @find_recipient = Recipient.where(:name => row['recipient']).first

      @countries = []
      if row['grant_countries']
        row['grant_countries'].split('; ').each do |c|
          @countries << Country.find_by_alpha2(c)
        end
      end

      @districts = []
      def find_regions(region)
        District.where(region: region).each { |d| @districts << d }
      end
      def find_sub_country(sub_country)
        District.where(sub_country: sub_country).each { |d| @districts << d }
      end

      if row['grant_districts']
        row['grant_districts'].split('; ').each do |d|
          case d

          when 'London'
            find_regions('London')
          when 'West Midlands'
            find_regions('West Midlands')
          when 'East Midlands'
            find_regions('East Midlands')
          when 'Yorkshire and The Humber' || 'Yorkshire & The Humber'
            find_regions('Yorkshire and The Humber')
          when 'East of England'
            find_regions('East of England')
          when 'North West'
            find_regions('North West')
          when 'North East'
            find_regions('North East')
          when 'South West'
            find_regions('South West')
          when 'South East'
            find_regions('South East')
          when 'England'
            find_sub_country('England')
          when 'Northern Ireland'
            find_sub_country('Northern Ireland')
          when 'Scotland'
            find_sub_country('Scotland')
          when 'Wales'
            find_sub_country('Wales')
          when 'UK wide'
            District.where(country_id: Country.find_by_alpha2('GB').id).each do |d|
              @districts << d
            end
          else
            @districts << District.find_by_district(d)
          end
        end
      end

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
        :applied_on => row['applied_on'],
        :open_call => row['open_call'],
        :countries => @countries,
        :districts => @districts
      }

      grant = Grant.new(grant_values)
      grant.skip_validation = @skip_validation

      if grant.valid?
        grant.save if ENV['SAVE']
        grant_count += 1
      else
        @messages << "\n#{recipient.name}"
        @messages << "Grant: #{grant.errors.messages}"
      end

    end

    puts @messages
    puts "#{recipient_count} Recipient's created"
    puts "#{grant_count} Grant's created"

  end
end

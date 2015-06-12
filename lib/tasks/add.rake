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

      @london = []

      @west_midlands = ["Herefordshire, County of", "Shropshire", "Telford and Wrekin", "East Staffordshire", "Cannock Chase", "Lichfield", "Newcastle-under-Lyme", "South Staffordshire", "Stafford", "Staffordshire Moorlands", "Tamworth", "Stoke-on-Trent", "North Warwickshire", "Nuneaton and Bedworth", "Rugby", "Stratford-on-Avon", "Warwick", "Birmingham", "Coventry", "Dudley", "Sandwell", "Solihull", "Walsall", "Bromsgrove", "Malvern Hills", "Redditch", "Worcester", "Wychavon", "Wyre Forest"]

      @east_midlands = ["High Peak", "Derbyshire Dales", "South Derbyshire", "Erewash", "Amber Valley", "North East Derbyshire", "Chesterfield", "Bolsover", "Derby", "Rushcliffe", "Broxtowe", "Ashfield", "Gedling", "Newark and Sherwood", "Mansfield", "Bassetlaw", "Nottingham", "Lincoln", "North Kesteven", "South Kesteven", "South Holland", "Boston", "East Lindsey", "West Lindsey", "Charnwood", "Melton", "Harborough", "Oadby and Wigston", "Blaby", "Hinckley and Bosworth", "North West Leicestershire", "Leicester", "Rutland", "South Northamptonshire", "Northampton", "Daventry", "Wellingborough", "Kettering", "Corby", "East Northamptonshire"]

      @yorkshire_and_the_humber = ["Sheffield", "Rotherham", "Barnsley", "Doncaster", "Wakefield", "Kirklees", "Calderdale", "Bradford", "Leeds", "Selby", "Harrogate", "Craven", "Richmondshire", "Hambleton", "Ryedale", "Scarborough", "York", "East Riding of Yorkshire", "Kingston upon Hull, City of", "North Lincolnshire", "North East Lincolnshire"]

      @east_of_england = ["Thurrock", "Southend-on-Sea", "Harlow", "Epping Forest", "Brentwood", "Basildon", "Castle Point", "Rochford", "Maldon", "Chelmsford", "Uttlesford", "Braintree", "Colchester", "Tendring", "Three Rivers", "Watford", "Hertsmere", "Welwyn Hatfield", "Broxbourne", "East Hertfordshire", "Stevenage", "North Hertfordshire", "St Albans", "Dacorum", "Luton", "Bedford", "Central Bedfordshire", "Cambridge", "South Cambridgeshire", "Huntingdonshire", "Fenland", "East Cambridgeshire", "Peterborough", "Norwich", "South Norfolk", "Great Yarmouth", "Broadland", "North Norfolk", "Breckland", "King's Lynn and West Norfolk", "Ipswich", "Suffolk Coastal", "Waveney", "Mid Suffolk", "Babergh", "St Edmundsbury", "Forest Heath"]

      @north_west = ["Cheshire East", "Cheshire West and Chester", "Halton", "Warrington", "Barrow-in-Furness", "South Lakeland", "Copeland", "Allerdale", "Eden", "Carlisle", "Bolton", "Bury", "Manchester", "Oldham", "Rochdale", "Salford", "Stockport", "Tameside", "Trafford", "Wigan", "West Lancashire", "Chorley", "South Ribble", "Fylde", "Preston", "Wyre", "Lancaster", "Ribble Valley", "Pendle", "Burnley", "Rossendale", "Hyndburn", "Blackpool", "Blackburn with Darwen", "Knowsley", "Liverpool", "St. Helens", "Sefton", "Wirral"]

      @north_east = ["Northumberland", "Newcastle upon Tyne", "Gateshead", "North Tyneside", "South Tyneside", "Sunderland", "County Durham", "Darlington", "Hartlepool", "Stockton-on-Tees", "Redcar and Cleveland", "Middlesbrough"]

      @south_west = ["Bath and North East Somerset", "North Somerset", "South Somerset", "Taunton Deane", "West Somerset", "Sedgemoor", "Mendip", "South Gloucestershire", "Gloucester", "Tewkesbury", "Cheltenham", "Cotswold", "Stroud", "Forest of Dean", "Swindon", "Wiltshire", "Weymouth and Portland", "East Dorset", "North Dorset", "West Dorset", "Purbeck", "Christchurch", "Poole", "Bournemouth", "Exeter", "East Devon", "Mid Devon", "North Devon", "West Devon", "Torridge", "South Hams", "Teignbridge", "Torbay", "Plymouth", "Isles of Scilly", "Cornwall"]

      @south_east = ["West Berkshire", "Reading", "Wokingham", "Bracknell Forest", "Windsor and Maidenhead", "Slough", "South Bucks", "Chiltern", "Wycombe", "Aylesbury Vale", "Milton Keynes", "Hastings", "Rother", "Wealden", "Eastbourne", "Lewes", "Brighton and Hove", "Fareham", "Gosport", "Winchester", "Havant", "East Hampshire", "Hart", "Rushmoor", "Basingstoke and Deane", "Test Valley", "Eastleigh", "New Forest", "Southampton", "Portsmouth", "Isle of Wight", "Dartford", "Gravesham", "Sevenoaks", "Tonbridge and Malling", "Tunbridge Wells", "Maidstone", "Swale", "Ashford", "Shepway", "Canterbury", "Dover", "Thanet", "Medway", "Oxford", "Cherwell", "South Oxfordshire", "West Oxfordshire", "Vale of White Horse", "Spelthorne", "Runnymede", "Surrey Heath", "Woking", "Elmbridge", "Guildford", "Waverley", "Mole Valley", "Epsom and Ewell", "Reigate and Banstead", "Tandridge", "Worthing", "Arun", "Chichester", "Horsham", "Crawley", "Mid Sussex", "Adur"]

      @districts = []
      if row['grant_districts']
        row['grant_districts'].split('; ').each do |d|
          case d

          when 'London'
            @london.each do |d|
              @districts << District.find_by_district(d)
            end
          when 'West Midlands'
            @west_midlands.each do |d|
              @districts << District.find_by_district(d)
            end
          when 'East Midlands'
            @east_midlands.each do |d|
              @districts << District.find_by_district(d)
            end
          when 'Yorkshire and The Humber' || 'Yorkshire & The Humber'
            @yorkshire_and_the_humber.each do |d|
              @districts << District.find_by_district(d)
            end
          when 'East of England'
            @east_of_england.each do |d|
              @districts << District.find_by_district(d)
            end
          when 'North West'
            @north_west.each do |d|
              @districts << District.find_by_district(d)
            end
          when 'North East'
            @north_east.each do |d|
              @districts << District.find_by_district(d)
            end
          when 'South West'
            @south_west.each do |d|
              @districts << District.find_by_district(d)
            end
          when 'South East'
            @south_east.each do |d|
              @districts << District.find_by_district(d)
            end
          # when 'England'
          #   @districts << District.find_by_district('England')
          #   [@london, @west_midlands, @east_midlands, @yorkshire_and_the_humber, @east_of_england, @north_west, @north_east, @south_west, @south_east].flatten.each do |d|
          #     @districts << District.find_by_district(d)
          #   end
          # when 'Northern Ireland'
          #   @districts << District.find_by_district('Northern Ireland')
          #   @northern_ireland.each do |d|
          #     @districts << District.find_by_district(d)
          #   end
          # when 'Scotland'
          #   @districts << District.find_by_district('Scotland')
          #   @scotland.each do |d|
          #     @districts << District.find_by_district(d)
          #   end
          # when 'Wales'
          #   @districts << District.find_by_district('Wales')
          #   @wales.each do |d|
          #     @districts << District.find_by_district(d)
          #   end
          # when 'UK'
          #   @districts << District.find_by_district('England')
          #   @districts << District.find_by_district('Northern Ireland')
          #   @districts << District.find_by_district('Scotland')
          #   @districts << District.find_by_district('Wales')
          #   [@england, @northern_ireland, @scotland, @wales].flatten.each do |d|
          #     @districts << District.find_by_district(d)
          #   end
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
    puts "#{grant_count} Recipient's created"

  end
end

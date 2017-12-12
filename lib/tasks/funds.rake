namespace :funds do
  include ActionView::Helpers::TextHelper

  # usage: rake funds:update FUNDS='fund-slug1, fund-slug2'
  desc 'Update specified funds'
  task update: :environment do
    Fund.where(slug: ENV['FUNDS'].try(:split, ', ')).each do |fund|
      fund.save!
      puts fund.slug + ' saved'
    end
  end

  # usage: rake funds:update_all!
  desc 'Update all funds with open data'
  task update_all!: :environment do
    Fund.where(open_data: true).each do |fund|
      fund.save!
      puts fund.slug + ' saved'
    end
  end

  # usage: rake funds:themes THEMES=/path/to/file.json RELATED=true SAVE=true
  desc 'Update themes'
  task themes: :environment do
    open(ENV['THEMES']) do |f|
      JSON.parse(f.read).each do |k, v|
        theme = Theme.where(name: k).first_or_initialize
        theme.parent = Theme.find_by name: v['parent']
        theme.related = v['related'] if ENV['RELATED']
        print theme.valid? ? '.' : '*'
        theme.save! if ENV['SAVE']
      end
      puts "\n"
    end
  end

  # usage: rake funds:fund_themes! FUND_THEMES=/path/to/file.json SAVE=true
  desc 'Add themes to funds'
  task fund_themes!: :environment do
    open(ENV['FUND_THEMES']) do |f|
      JSON.parse(f.read).each do |k, v|
        fund = Fund.find_by slug: k
        next unless fund
        fund.assign_attributes themes: Theme.where(name: v)
        print fund.valid? ? '.' : '*'
        fund.save! if ENV['SAVE'] and fund.valid?
      end
      puts "\n"
    end
  end

  # usage: rake funds:fetch_stubs
  # usage: rake funds:fetch_stubs SAVE=true
  # usage: rake funds:fetch_stubs SAVE=true COUNTRIES=GB,US BENEFICIARIES='PEOPLE WITH DISABILITIES' ACTIVITIES= PURPOSE=
  desc 'Fetch fund stubs from Beehive data'
  task fetch_stubs: :environment do
    # needs BEEHIVE_DATA_STUB_FUNDS_ENDPOINT to be set
    options = {
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => 'Token token=' + ENV['BEEHIVE_DATA_TOKEN']
      },
      query: {}
    }
    options[:query][:country] = ENV['COUNTRY'] if ENV['COUNTRY']
    # Optional - comma-separated, use ISO3166-1 2-digit code

    options[:query][:beneficiaries] = ENV['BENEFICIARIES'] if ENV['BENEFICIARIES']
    # Optional - comma-separated, choose from:
    # - "CHILDREN/YOUNG PEOPLE"
    # - "ELDERLY/OLD PEOPLE"
    # - "PEOPLE WITH DISABILITIES"
    # - "PEOPLE OF A PARTICULAR ETHNIC OR RACIAL ORIGIN"
    # - "OTHER CHARITIES OR VOLUNTARY BODIES"
    # - "OTHER DEFINED GROUPS"
    # - "THE GENERAL PUBLIC/MANKIND"

    options[:query][:activities] = ENV['ACTIVITIES'] if ENV['ACTIVITIES']
    # Optional - comma-separated, choose from:
    # - "MAKES GRANTS TO INDIVIDUALS"
    # - "MAKES GRANTS TO ORGANISATIONS"
    # - "PROVIDES OTHER FINANCE"
    # - "PROVIDES HUMAN RESOURCES"
    # - "PROVIDES BUILDINGS/FACILITIES/OPEN SPACE"
    # - "PROVIDES SERVICES"
    # - "PROVIDES ADVOCACY/ADVICE/INFORMATION"
    # - "SPONSORS OR UNDERTAKES RESEARCH"
    # - "ACTS AS AN UMBRELLA OR RESOURCE BODY"
    # - "OTHER CHARITABLE ACTIVITIES"

    options[:query][:purpose] = ENV['PURPOSE'] if ENV['PURPOSE']
    # Optional - comma-separated, choose from:
    # - "GENERAL CHARITABLE PURPOSES"
    # - "EDUCATION/TRAINING"
    # - "THE ADVANCEMENT OF HEALTH OR SAVING OF LIVES"
    # - "DISABILITY"
    # - "THE PREVENTION OR RELIEF OF POVERTY"
    # - "OVERSEAS AID/FAMINE RELIEF"
    # - "ACCOMMODATION/HOUSING"
    # - "RELIGIOUS ACTIVITIES"
    # - "ARTS/CULTURE/HERITAGE/SCIENCE"
    # - "AMATEUR SPORT"
    # - "ANIMALS"
    # - "ENVIRONMENT/CONSERVATION/HERITAGE"
    # - "ECONOMIC/COMMUNITY DEVELOPMENT/EMPLOYMENT"
    # - "ARMED FORCES/EMERGENCY SERVICE EFFICIENCY"
    # - "HUMAN RIGHTS/RELIGIOUS OR RACIAL HARMONY/EQUALITY OR DIVERSITY"
    # - "RECREATION"
    # - "OTHER CHARITABLE PURPOSES"
    
    # Optional - number of funders returned - default is 50, max is 1000
    options[:query][:limit] = ENV['LIMIT'] if ENV['LIMIT'] 
    # Optional - minimum size of funders returned (by grants made) - default is 100000
    options[:query][:min_size] = ENV['MIN_SIZE'] if ENV['MIN_SIZE'] 
  
    response = HTTParty.get(
      ENV['BEEHIVE_DATA_STUB_FUNDS_ENDPOINT'], 
      options
    )
    funders = JSON.parse(response.body)

    puts "Found #{pluralize(funders.size, "funder")}"

    gb = Country.find_by(alpha2: 'GB')
    funders.each do |f|
      # find funder first
      funder = Funder.where('name = ? OR charity_number = ?', f["name"], f["reg_number"]).first_or_initialize
      unless funder.persisted?
        funder.name = f["name"]
        funder.charity_number = f["reg_number"]
      end
      funder.website = f['website'].sub(/^www./, 'http://www.') unless funder.website
      unless funder.valid?
        next
      end
      funder.save if ENV["SAVE"]
      fund_count = funder.funds.where.not(state: 'draft').count

      puts 
      puts funder.name
      puts "=" * funder.name.size

      if fund_count > 0
        puts "Funder has #{pluralize(fund_count, "existing fund")}"
        puts "No update"
        next
      end

      # only funders who have draft funds or no funds
      fund = funder.funds.where(state: 'draft').first

      themes = Theme.where(name: f['themes']).to_a

      if f["countries"].blank? and f["districts"].blank?
        f["countries"] = ["Other"]
      end

      if f["geo_area"] =~ /\d/ or f["geo_area"].blank?
        geo_area_name = f["countries"].uniq.sort.join(",") + ";" + f["districts"].uniq.sort.join(",")
      else
        geo_area_name = f["geo_area"]
      end

      geo_area = GeoArea.where(name: geo_area_name).first_or_initialize
      unless geo_area.persisted?
        geo_area.name = geo_area_name
        geo_area.short_name = f["geo_area"]
        geo_area.countries = Country.where(alpha2: f["countries"])
        geo_area.districts = f["districts"].select{|d| d.present? }
                                            .map{ |d| District.where("subdivision LIKE ? and country_id = ?", "#{d}%", gb.id)}
                                            .flatten.uniq
        geo_area.save! if ENV['SAVE']
        puts "New geo area created: [#{geo_area.short_name}]"
      end

      params = {
        funder: funder,
        name: 'Main Fund',
        description: f['description'],
        themes: themes,
        geo_area: geo_area
      }

      if fund
        update = fund.update(params)
        if update
          puts "Updating draft fund id #{fund.id}"
        else
          puts "Could not update draft fund id #{fund.id}"
        end
      else
        stub = FundStub.new(params)
        if stub.valid?
          puts "Saving new draft fund"
        else
          puts "Could not save new draft fund"
        end
        stub.save if ENV['SAVE']
      end
      
    end
  end
end

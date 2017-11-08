namespace :funds do
  # usage: rake funds:update FUNDS='fund-slug1, fund-slug2'
  desc 'Update specified funds'
  task update: :environment do
    Fund.where(slug: ENV['FUNDS'].try(:split, ', ')).each do |fund|
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
  desc 'Fetch fund stubs from Beehive data'
  task fetch_stubs: :environment do
    # accepts optional parameters:
    #  - number of funds
    #  - country covered?
    #  - beneficiaries/themes
    #  - skip/save on duplicate
    # calls API
    # get list of objects
    # loop objects
    # find existing (and skip/update) or create new
    # BEEHIVE_DATA_STUB_FUNDS_ENDPOINT
    options = {
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => 'Token token=' + ENV['BEEHIVE_DATA_TOKEN']
      }
    }
    response = HTTParty.get(ENV['BEEHIVE_DATA_STUB_FUNDS_ENDPOINT'], options)
    funders = JSON.parse(response.body)
    funders.each do |f|
      # find funder first
      funder = Funder.where('name = ? OR charity_number = ?', f["name"], f["reg_number"]).first_or_initialize
      unless funder.persisted?
        funder.name = f["name"]
        funder.charity_number = f["reg_number"]
      end
      funder.website = f["website"] unless funder.website.present?
      funder.save! if ENV["SAVE"]

      
      # find existing fund
      # Fund.where()
      # puts f["name"]
    end
  end
end

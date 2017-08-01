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
        theme.parent = Theme.find_by(name: v['parent'])
        theme.related = v['related'] if ENV['RELATED']
        print theme.valid? ? '.' : '*'
        theme.save! if ENV['SAVE']
      end
      puts "\n"
    end
  end
end

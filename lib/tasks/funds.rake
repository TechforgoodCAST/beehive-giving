namespace :funds do
  # usage: rake funds:update FUNDS='fund-slug1, fund-slug2'
  desc 'Update specified funds'
  task update: :environment do
    Fund.where(slug: ENV['FUNDS'].try(:split, ', ')).each do |fund|
      fund.save!
      puts fund.slug + ' saved'
    end
  end
end

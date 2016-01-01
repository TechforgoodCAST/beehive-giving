namespace :notifications do

  # usage: be rake notifications:send
  desc 'Email a daily summary user activity to admins'
  task :send => :environment do
    AdminUser.all.each { |admin| UserMailer.admin_summary(admin).deliver }
  end

end

namespace :missing do

  # usage: be rake missing:organisations DESTINATON="/path"
  desc "List of users missing organisations"
  task :organisations => :environment do

    require 'csv'
    @destination = ENV['DESTINATION']

    CSV.open(@destination, "w+") do |csv|
      csv << ["First Name", "User Email", "Created On", "Last Seen"]
    end

    User.where(:organisation_id => nil).each do |user|

      row = []
      row << "#{user.first_name}"
      row << "#{user.user_email}"
      row << "#{user.created_at.strftime('%F')}"
      row << "#{user.last_seen.strftime('%F')}" if user.last_seen

      CSV.open(@destination, "a+") do |csv|
        csv << [row[0], row[1], row[2], row[3]]
      end
    end
  end

  # usage: be rake missing:profiles DESTINATON="/path"
  desc "List of recipients missing profiles"
  task :profiles => :environment do

    require 'csv'
    @destination = ENV['DESTINATION']

    CSV.open(@destination, "w+") do |csv|
      csv << ["First Name", "User Email", "Created On", "Last Seen"]
    end

    Recipient.joins(:users).includes(:profiles).where(:profiles => { :organisation_id => nil } ).each do |recipient|

      row = []
      row << "#{recipient.users.first.first_name}"
      row << "#{recipient.users.first.user_email}"
      row << "#{recipient.users.first.created_at.strftime('%F')}"
      row << "#{recipient.users.first.last_seen.strftime('%F')}" if recipient.users.first.last_seen.present?

      CSV.open(@destination, "a+") do |csv|
        csv << [row[0], row[1], row[2], row[3]]
      end
    end
  end

  # # usage: be rake missing:profiles DESTINATON="/path"
  # desc "List of recipients with profiles missing feedback"
  # task :feedback => :environment do
  #
  #   require 'csv'
  #   @destination = ENV['DESTINATION']
  #
  #   CSV.open(@destination, "w+") do |csv|
  #     csv << ["First Name", "User Email", "Created On", "Last Seen"]
  #   end
  #
  #   Recipient.joins(:users).includes(:profiles).where(:profiles => { :organisation_id => nil } ).each do |recipient|
  #
  #     row = []
  #     row << "#{recipient.users.first.first_name}"
  #     row << "#{recipient.users.first.user_email}"
  #     row << "#{recipient.users.first.created_at.strftime('%F')}"
  #     row << "#{recipient.users.first.last_seen.strftime('%F')}" if recipient.users.first.last_seen.present?
  #
  #     CSV.open(@destination, "a+") do |csv|
  #       csv << [row[0], row[1], row[2], row[3]]
  #     end
  #   end
  # end

end

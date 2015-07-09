namespace :missing do

  # usage: be rake missing:master DESTINATON=/path DAYS_AGO=2
  desc "Master list"
  task :master => :environment do

    require 'csv'
    @destination = ENV['DESTINATION']
    @days_ago = ENV['DAYS_AGO'] || 365

    CSV.open(@destination, "w+") do |csv|
      csv << ["First Name", "Last Name", "User Email", "Created On", "Last Seen",
              "Organisation", "Contact number", "Profiles", "Unlocks",
              "Eligibilities", "Requests", "Feedbacks", "NPS", "Taken Away", "Informs Decision"]
    end

    User.where('role = ? AND created_at >= ?', 'User', Date.today - @days_ago.to_i).order(:created_at).each do |user|

      row = []
      puts "#{user.first_name}"
      row << "#{user.first_name}"
      row << "#{user.last_name}"
      row << "#{user.user_email}"
      row << "#{user.created_at.strftime('%F')}"
      row << (user.last_seen ? "#{user.last_seen.strftime('%F')}" : "-")
      if user.organisation
        @recipient = Recipient.find(user.organisation.id)
        row << "#{user.organisation.name}"
        row << "#{user.organisation.contact_number}"
        row << "#{user.organisation.profiles.count}"
        row << "#{RecipientFunderAccess.where(recipient_id: @recipient.id).count}"
        row << "#{Eligibility.where(recipient_id: @recipient.id).count}"
        row << "#{Feature.where(recipient_id: @recipient.id).count}"
        row << "#{Feedback.where(user: user).count}"
        if user.feedbacks.count > 0
          row << "#{user.feedbacks.first.nps}"
          row << "#{user.feedbacks.first.taken_away}"
          row << "#{user.feedbacks.first.informs_decision}"
        else
          3.times { |i| row << "-" }
        end
      else
        if user.feedbacks.count > 0
          7.times { |i| row << "-" }
        else
          10.times { |i| row << "-" }
        end
      end

      CSV.open(@destination, "a+") do |csv|
        csv << [row[0], row[1], row[2], row[3], row[4], row[5], row[6],
                row[7], row[8], row[9], row[10], row[11], row[12], row[13],
                row[14], row[15]]
      end
    end
  end

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

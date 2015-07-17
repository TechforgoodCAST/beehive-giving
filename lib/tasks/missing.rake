namespace :missing do

  # usage: be rake missing:master DESTINATON=/path DAYS_AGO=2
  desc "Master list"
  task :master => :environment do

    require 'csv'
    @destination = ENV['DESTINATION']
    @days_ago = ENV['DAYS_AGO'] || 365

    CSV.open(@destination, "w+") do |csv|
      csv << ["Last Updated", "First Name", "Last Name", "User Email", "Created On",
              "Last Seen", "Organisation", "Contact number", "Profiles", "Unlocks",
              "Eligibilities", "Requests", "Feedbacks", "NPS", "Taken Away",
              "Informs Decision"]
    end

    User.where('role = ? AND created_at >= ?', 'User', Date.today - @days_ago.to_i).order(:created_at).each do |user|

      row = []
      row << "#{Date.today}"
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
                row[14], row[15], row[16]]
      end
    end
  end
end

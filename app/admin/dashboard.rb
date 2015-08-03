ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do

    div class: "blank_slate_container" do
      div style: "float:left; width: 20%;" do
        span class: "blank_slate" do
          h3 'Users'
          h5 'Non-profits'
          h1 User.where("role = ?", "User").count
          h5 'Funders'
          h1 User.where("role = ?", "Funder").count
        end
      end

      div style: "float:left; width: 40%;" do
        span class: "blank_slate" do
          h3 'Non-profits'
          h5 'Recipients'
          h1 Recipient.joins(:users).all.count
          h5 'Profiles'
          h1 Profile.joins(:organisation).all.count
        end

        span class: "blank_slate" do
          h3 'Non-profits'
          h5 'Unlocks'
          h1 RecipientFunderAccess.all.count
          h5 'Eligibilities'
          h1 Eligibility.all.count
        end

        span class: "blank_slate" do
          h3 'Other'
          h5 'Feedback'
          h1 Feedback.all.count
          h5 'Requests'
          h1 Feature.all.count
        end
      end

      div style: "float:left; width: 40%;" do
        span class: "blank_slate" do
          h3 'Funders'
          h5 'Active'
          h1 Funder.where("active_on_beehive = ?", true).count
          h5 'Total'
          h1 Funder.all.count
        end

        span class: "blank_slate" do
          h3 'Funders'
          h5 'Grants'
          h1 Grant.all.count
        end

        span class: "blank_slate" do
          h3 'Funders'
          h5 'Funding streams'
          h1 FundingStream.all.uniq.count
          h5 'Restrictions'
          h1 Restriction.all.count
        end
      end
    end

    def user_count
      User.where(role: 'User').group_by_week(:created_at, week_start: :mon, last: 4, format: 'w/o %d %b').count
    end

    def recipient_count
      Recipient.joins(:users).group_by_week('users.created_at', week_start: :mon, last: 4).count
    end

    def profile_count
      Profile.select(:organisation_id).group_by_week(:created_at, week_start: :mon, last: 4).count
    end

    def unlock_count
      RecipientFunderAccess.select(:recipient_id).distinct.group_by_week(:created_at, week_start: :mon, last: 4).count
    end

    def eligibility_count
      Eligibility.select(:recipient_id).distinct.group_by_week(:created_at, week_start: :mon, last: 4).count
    end

    def percentage(count, i)
      "#{count[1]} (#{number_to_percentage((count[1].to_d / user_count.to_a[i][1].to_d)*100, precision: 0)})"
    end

    div style: "float:left; width: 100%; padding: 0 20px; box-sizing: border-box;" do
      section "Conversion" do
        table do
          thead do
            tr do
              th 'Stage'
              user_count.each { |i| th i[0] }
            end
          end
          tr do
            td 'Sign up'
            user_count.each { |i| td i[1] }
          end
          tr do
            td 'Register non-profit'
            recipient_count.each_with_index do |count, i|
              td percentage(count, i) if count[1] > 0
            end
          end
          tr do
            td 'Create profile'
            profile_count.each_with_index do |count, i|
              td percentage(count, i) if count[1] > 0
            end
          end
          tr do
            td 'Funder unlocks'
            unlock_count.each_with_index do |count, i|
              td percentage(count, i) if count[1] > 0
            end
          end
          tr do
            td 'Eligibility checks'
            eligibility_count.each_with_index do |count, i|
              td percentage(count, i) if count[1] > 0
            end
          end
        end
      end
    end

    div style: "float:left; width: 50%; padding: 0 20px; box-sizing: border-box;" do
      section "User activation by day" do
        @metric = User.where("role = ?", "User").group_by_day(:created_at, week_start: :mon, range: 2.weeks.ago..Time.now).count
        render :partial => 'metrics/line_chart', :locals => {:metric => @metric}
      end
    end

    div style: "float:left; width: 50%; padding: 0 20px; box-sizing: border-box;" do
      section "User activation by week" do
        @metric = User.where("role = ?", "User").group_by_week(:created_at, week_start: :mon, range: Time.new(2015,03,01,00,00,00)..Time.now).count
        render :partial => 'metrics/line_chart', :locals => {:metric => @metric}
      end
    end

    div style: "float:left; width: 50%; padding: 0 20px; box-sizing: border-box;" do
      section "Non-profits by country" do
        @metric = Recipient.joins(:users).group(:country).count
        render :partial => 'metrics/geo_chart', :locals => {:metric => @metric}
      end
    end

    div style: "float:left; width: 50%; padding: 0 20px; box-sizing: border-box;" do
      section "Recent Non-profits" do
        table_for Recipient.joins(:users).order("created_at desc").limit(5) do
          column :name do |recipient|
            link_to recipient.name, [:admin, recipient]
          end
          column :country
          column :created_at
        end
      end
    end

  end
end

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

    # def week(week)
    #   week.weeks.ago.beginning_of_week(:monday).strftime('w/o %d %b')
    # end
    #
    # def user_count(week_start, week_end)
    #   User.where("role = ?", "User").group_by_week(:created_at, week_start: :mon, range: week_start.weeks.ago..week_end.weeks.ago).count.first[1].to_d
    # end
    #
    # def recipient_count(week_start, week_end)
    #   Recipient.joins(:users).group_by_week("users.created_at", week_start: :mon, range: week_start.weeks.ago..week_end.weeks.ago).count.first[1].to_d
    # end
    #
    # def profile_count(week_start, week_end)
    #   Profile.group_by_week(:created_at, week_start: :mon, range: week_start.weeks.ago..week_end.weeks.ago).count.first[1].to_d
    # end
    #
    # def recipient_percentage(week_start, week_end)
    #   "#{recipient_count(week_start, week_end).to_i} (#{number_to_percentage((recipient_count(week_start, week_end) / user_count(week_start, week_end))*100, precision: 0)})"
    # end
    #
    # def profile_percentage(week_start, week_end)
    #   "#{profile_count(week_start, week_end).to_i} (#{number_to_percentage((profile_count(week_start, week_end) / user_count(week_start, week_end))*100, precision: 0)})"
    # end

    # div style: "float:left; width: 100%; padding: 0 20px; box-sizing: border-box;" do
    #   section "Conversion" do
    #     table do
    #       thead do
    #         tr do
    #           th 'Stage'
    #           th week(1)
    #           th week(2)
    #           th week(3)
    #           th week(4)
    #         end
    #       end
    #       tr do
    #         td 'Sign up'
    #         td user_count(1, 0).to_i
    #         td user_count(2, 1).to_i
    #         td user_count(3, 2).to_i
    #         td user_count(4, 3).to_i
    #       end
    #       tr do
    #         td 'Register non-profit'
    #         td recipient_percentage(1, 0)
    #         td recipient_percentage(2, 1)
    #         td recipient_percentage(3, 2)
    #         td recipient_percentage(4, 3)
    #       end
    #       tr do
    #         td 'Create profile'
    #         td profile_percentage(1, 0)
    #         td profile_percentage(2, 1)
    #         td profile_percentage(3, 2)
    #         td profile_percentage(4, 3)
    #       end
    #     end
    #   end
    # end

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

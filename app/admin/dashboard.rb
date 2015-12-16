ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do

    div class: "blank_slate_container" do
      div style: "float:left; width: 20%;" do
        span class: "blank_slate" do
          h3 'Users'
          h5 'Non-profits'
          h1  number_with_delimiter(User.where("role = ?", "User").count)
          h5 'Funders'
          h1 User.where("role = ?", "Funder").count
        end
      end

      div style: "float:left; width: 40%;" do
        span class: "blank_slate" do
          h3 'Non-profits'
          h5 'Recipients'
          h1 number_with_delimiter(Recipient.joins(:users).all.count)
          h5 'Profiles'
          h1 Profile.joins(:organisation).all.count
        end

        span class: "blank_slate" do
          h3 'Non-profits'
          h5 'Unlocks'
          h1 RecipientFunderAccess.all.count
          h5 'Eligibilities'
          h1 number_with_delimiter(Eligibility.all.count)
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
          h1 number_with_delimiter(Grant.all.count)
          h5 'Proposals'
          h1 Proposal.all.count
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
      User.where(role: 'User').group_by_week(:created_at, week_start: :mon, last: 6, format: 'w/o %d %b').count
    end

    def recipient_count
      Recipient.joins(:users).group_by_week('users.created_at', week_start: :mon, last: 6).count
    end

    def profile_count
      Profile.where(state: 'complete').select(:organisation_id).group_by_week(:created_at, week_start: :mon, last: 6).count
    end

    def unlock_count(count)
      Recipient.joins(:recipient_funder_accesses).where('recipient_funder_accesses_count = ?', count).uniq.group_by_week('recipient_funder_accesses.created_at', week_start: :mon, last: 6).count
    end

    def proposal_count(count)
      Proposal.group_by_week(:created_at, week_start: :mon, last: 6).count
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
            td '1 Funder unlock'
            unlock_count(1).each_with_index do |count, i|
              td percentage(count, i) if count[1] > 0
            end
          end
          tr do
            td '2 Funder unlocks'
            unlock_count(2).each_with_index do |count, i|
              td percentage(count, i) if count[1] > 0
            end
          end
          tr do
            td '3 Funder unlocks'
            unlock_count(3).each_with_index do |count, i|
              td percentage(count, i) if count[1] > 0
            end
          end
          tr do
            td 'Proposals'
            proposal_count(3).each_with_index do |count, i|
              td count[1] > 0 ? percentage(count, i) : '-'
            end
          end
        end
      end
    end

    div style: "float:left; width: 50%;" do
      section "Activity by day (2 weeks)" do
        render :partial => 'metrics/daily_chart', :locals => {:metric => @metric}
      end
    end

    div style: "float:left; width: 50%;" do
      section "Activity by week (12 weeks)" do
        render :partial => 'metrics/weekly_chart', :locals => {:metric => @metric}
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

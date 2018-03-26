ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    div class: 'blank_slate_container' do
      div style: 'float:left; width: 20%;' do
        span class: 'blank_slate' do
          h3 'Users'
          h5 'Non-profits'
          h1 number_with_delimiter(User.recipient.count)
          h5 'Funders'
          h1 User.funder.count
        end
      end

      div style: 'float:left; width: 40%;' do
        span class: 'blank_slate' do
          h3 'Non-profits'
          h5 'Recipients'
          h1 number_with_delimiter Recipient.joins(:users).all.count
          h5 'Proposals'
          h1 number_with_delimiter Proposal.all.count
        end

        span class: 'blank_slate' do
          h3 'Non-profits'
          h5 'Quiz answers'
          h1 number_with_delimiter Answer.all.count
        end

        span class: 'blank_slate' do
          h3 'Other'
          h5 'Feedback'
          h1 Feedback.all.count
        end
      end

      div style: 'float:left; width: 40%;' do
        span class: 'blank_slate' do
          h3 'Funders'
          h5 'Active'
          h1 Funder.where(active: true).count
          h5 'Total'
          h1 Funder.all.count
        end

        span class: 'blank_slate' do
          h3 'Funds'
          h5 'Active'
          h1 Fund.active.count
          h5 'Restrictions'
          h1 Restriction.all.count
        end
      end
    end

    def user_count
      User.recipient.group_by_week(
        :created_at, week_start: :mon, last: 12, format: 'w/o %d %b'
      ).count
    end

    def user_count_by_month
      User.recipient.group_by_month(:created_at, last: 12, format: '%b %Y').count
    end

    def recipient_count
      Recipient.joins(:users)
               .group_by_week('users.created_at',
                              week_start: :mon,
                              last: 12).count
    end

    def recipient_count_by_month
      Recipient.joins(:users).group_by_month('users.created_at', last: 12).count
    end

    def unlock_by_month
      Recipient.where('funds_checked > ?', 0).group_by_month(:created_at, last: 12).count
    end

    def complete_by_month
      Assessment.where('eligibility_status != ?', INCOMPLETE)
                .group_by_month(:created_at, last: 12)
                .distinct.count(:proposal_id)
    end

    def proposal_count(state)
      Proposal.where(state: state)
              .group_by_week(:created_at, week_start: :mon, last: 12).count
    end

    def proposal_count_by_month
      Proposal.where(state: %w[registered complete])
              .group_by_month(:created_at, last: 12, format: '%b %Y').count
    end

    def feedback_count
      Feedback.group_by_week(:created_at, week_start: :mon, last: 12).count
    end

    def feedback_count_by_month
      Feedback.group_by_month(:created_at, last: 12).count
    end

    def percentage(count, i)
      percent = number_to_percentage(
        (count[1].to_d / user_count.to_a[i][1].to_d) * 100,
        precision: 0
      )
      "#{count[1]} (#{percent})"
    end

    div style: 'float:left;
                width: 100%;
                padding: 0 20px;
                box-sizing: border-box;' do
      section 'Conversion' do
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
              td percentage(count, i) if count[1].positive?
            end
          end
          tr do
            td 'Proposals'
            proposal_count(%w[initial registered complete])
              .each_with_index do |count, i|
                td percentage(count, i) if count[1].positive?
              end
          end
          tr do
            td 'Inital proposal'
            proposal_count('initial').each_with_index do |count, i|
              td percentage(count, i) if count[1].positive?
            end
          end
          tr do
            td 'Registered proposal'
            proposal_count('registered').each_with_index do |count, i|
              if count[1].positive?
                td percentage(count, i)
              else
                td '-'
              end
            end
          end
          tr do
            td 'Complete proposal'
            proposal_count('complete').each_with_index do |count, i|
              if count[1].positive?
                td percentage(count, i)
              else
                td '-'
              end
            end
          end
        end
      end
    end

    div style: 'float:left;
                width: 100%;
                padding: 0 20px;
                box-sizing: border-box;' do
      section 'Conversion by month' do
        table do
          thead do
            tr do
              th 'Stage'
              user_count_by_month.each { |i| th i[0] }
            end
          end
          tr do
            td 'Users'
            user_count_by_month.each { |i| td i[1] }
          end
          tr do
            td 'Recipients'
            recipient_count_by_month.each { |i| td i[1] }
          end
          tr do
            td 'Proposals'
            proposal_count_by_month.each { |i| td i[1] }
          end
          tr do
            td 'Eligibility checks'
            unlock_by_month.each { |i| td i[1] }
          end
          tr do
            td 'Complete checks'
            complete_by_month.each { |i| td i[1] }
          end
          tr do
            td 'Feedback'
            feedback_count_by_month.each { |i| td i[1] }
          end
        end
      end
    end

    div style: 'float:left; width: 50%;' do
      section 'Activity by day (2 weeks)' do
        render partial: 'metrics/daily_chart', locals: { metric: @metric }
      end
    end

    div style: 'float:left; width: 50%;' do
      section 'Activity by week (12 weeks)' do
        render partial: 'metrics/weekly_chart', locals: { metric: @metric }
      end
    end

    div style: 'float:left;
                width: 50%;
                padding: 0 20px;
                box-sizing: border-box;' do
      section 'Non-profits by country' do
        @metric = Recipient.joins(:users).group(:country).count
        render partial: 'metrics/geo_chart', locals: { metric: @metric }
      end
    end

    div style: 'float:left;
                width: 50%;
                padding: 0 20px;
                box-sizing: border-box;' do
      section 'Recent Non-profits' do
        table_for Recipient.joins(:users).order('created_at desc').limit(5) do
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

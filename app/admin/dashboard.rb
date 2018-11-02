ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    def group_by_day(query)
      query.group_by_day(
        :created_at, week_start: :mon, range: 2.weeks.ago..Time.now
      ).count
    end

    def group_by_week(query)
      query.group_by_week(
        :created_at, week_start: :mon, last: 12, format: 'w/o %d %b'
      ).count
    end

    def group_by_month(query)
      query.group_by_month(:created_at, last: 12, format: '%b %Y').count
    end

    div class: 'blank_slate_container' do
      div style: 'float:left; width: 20%;' do
        span class: 'blank_slate' do
          h3 'Users'
          h1 number_with_delimiter User.count
        end
      end

      div style: 'float:left; width: 40%;' do
        span class: 'blank_slate' do
          h3 'Recipients'
          h1 number_with_delimiter Recipient.count
        end

        span class: 'blank_slate' do
          h3 'Proposals'
          h1 number_with_delimiter Proposal.count
        end
      end

      div style: 'float:left; width: 40%;' do
        span class: 'blank_slate' do
          h3 'Active Providers'
          h1 Funder.where(active: true).count
        end

        span class: 'blank_slate' do
          h3 'Active Opportunities'
          h1 Fund.active.count
        end
      end
    end

    div style: 'float:left;
                width: 100%;
                padding: 0 20px;
                box-sizing: border-box;' do
      section 'Conversion by week' do
        table do
          thead do
            tr do
              th 'Stage'
              group_by_week(Recipient).each { |i| th i[0] }
            end
          end
          tr do
            td 'Recipients'
            group_by_week(Recipient).each { |_k, v| td v }
          end
          tr do
            td 'Proposals'
            group_by_week(Proposal).each { |_k, v| td v }
          end
          tr do
            td 'Users'
            group_by_week(User).each { |_k, v| td v }
          end
          tr do
            td 'Customers'
            query = User.where('stripe_user_id IS NOT null')
            group_by_week(query).each { |_k, v| td v }
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
              group_by_month(Recipient).each { |i| th i[0] }
            end
          end
          tr do
            td 'Recipients'
            group_by_month(Recipient).each { |_k, v| td v }
          end
          tr do
            td 'Proposals'
            group_by_month(Proposal).each { |_k, v| td v }
          end
          tr do
            td 'Users'
            group_by_month(User).each { |_k, v| td v }
          end
          tr do
            td 'Customers'
            query = User.where('stripe_user_id IS NOT null')
            group_by_month(query).each { |_k, v| td v }
          end
        end
      end
    end

    javascript_include_tag '//www.google.com/jsapi', 'chartkick'

    div style: 'float:left; width: 50%;' do
      section 'Activity by day (2 weeks)' do
        customers = User.where('stripe_user_id IS NOT null')
        data = [
          { name: 'Recipients', data: group_by_day(Recipient) },
          { name: 'Proposals',  data: group_by_day(Proposal) },
          { name: 'Users',     data: group_by_day(User) },
          { name: 'Customers', data: group_by_day(customers) }
        ]
        div(line_chart(data, height: '350px'))
      end
    end

    div style: 'float:left; width: 50%;' do
      section 'Activity by week (12 weeks)' do
        customers = User.where('stripe_user_id IS NOT null')
        data = [
          { name: 'Recipients', data: group_by_week(Recipient) },
          { name: 'Proposals',  data: group_by_week(Proposal) },
          { name: 'Users',     data: group_by_week(User) },
          { name: 'Customers', data: group_by_week(customers) }
        ]
        div(line_chart(data, height: '350px'))
      end
    end
  end
end

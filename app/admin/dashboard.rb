ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do

    div class: "blank_slate_container" do
      div style: "float:left; width: 20%;" do
        span class: "blank_slate" do
          h3 'Users'
          h1 User.all.count
        end
      end

      div style: "float:left; width: 50%;" do
        span class: "blank_slate" do
          h3 'Non-profits'
          h1 Recipient.all.count
        end

        span class: "blank_slate" do
          h3 'Profiles'
          h1 Profile.all.count
        end

        span class: "blank_slate" do
          h3 'Feedback'
          h1 Feedback.all.count
        end

        span class: "blank_slate" do
          h3 'Requests'
          h1 Feature.all.count
        end
      end

      div style: "float:left; width: 30%;" do
        span class: "blank_slate" do
          h3 'Funders'
          h1 Funder.all.count
        end

        span class: "blank_slate" do
          h3 'Grants'
          h1 Grant.all.count
        end
      end
    end

    div style: "float:left; width: 50%; padding: 0 20px; box-sizing: border-box;" do
      section "Recent Non-profits" do
        table_for Recipient.order("created_at desc").limit(5) do
          column :name do |recipient|
            link_to recipient.name, [:admin, recipient]
          end
          column :country
          column :created_at
        end
      end
    end

    div style: "float:left; width: 50%; padding: 0 20px; box-sizing: border-box;" do
      section "User Activation by week" do
        @metric = Recipient.group_by_week(:created_at).count
        render :partial => 'metrics/line_chart', :locals => {:metric => @metric}
      end
    end

  end
end

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
        @metric = User.where("role = ?", "User").group_by_week(:created_at).count
        render :partial => 'metrics/line_chart', :locals => {:metric => @metric}
      end
    end

  end
end

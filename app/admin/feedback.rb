ActiveAdmin.register Feedback do
  index do
    column "Organisation", :user do |feedback|
      link_to feedback.user.organisation.name, [:admin, feedback.user.organisation]
    end
    column "Contact", :user do |feedback|
      feedback.user.user_email
    end
    column "Net Promoter Score", :nps
    column :taken_away
    column :informs_decision
    column :other
    column :created_at
  end
end

ActiveAdmin.register User do
  config.sort_order = 'created_at_asc'
  config.per_page = 1000

  permit_params :first_name, :last_name, :job_role,
  :user_email, :password, :password_confirmation, :role, :organisation_id

  index do
    column "Organisation" do |user|
      if user.organisation
        link_to user.organisation.name, [:admin, user.organisation]
      end
    end
    column "Profiles" do |user|
      if user.organisation
        user.organisation.profiles.count
      end
    end
    column :first_name
    column :last_name
    column :user_email
    column :job_role
    column :role
    column :sign_in_count
    column :last_seen
    actions
  end

  filter :organisation
  filter :role
  filter :first_name
  filter :last_name
  filter :job_role
  filter :user_email
  filter :last_seen
  filter :sign_in_count

  form do |f|
    f.inputs "User Details" do
      f.input :organisation, required: true
      f.input :role
      f.input :first_name
      f.input :last_name
      f.input :job_role
      f.input :user_email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end
end

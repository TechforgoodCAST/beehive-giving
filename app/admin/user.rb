ActiveAdmin.register User do
  permit_params :first_name, :last_name, :job_role,
  :user_email, :password, :password_confirmation, :role

  index do
    column :first_name
    column :last_name
    column :user_email
    column :job_role
    column :role
    column "Organisation", :user do |user|
      link_to user.organisation.name, [:admin, user.organisation]
    end
    actions
  end
end

ActiveAdmin.register User do
  permit_params :email, :first_name, :last_name, :marketing_consent,
                :password_confirmation, :password

  member_action :impersonate do
    user = User.find(params[:id])
    cookies.encrypted[:auth_token] = user.auth_token
    redirect_to reports_path, notice: "Impersonating #{user.email}"
  end

  index do
    column :id
    column :first_name
    column :last_name
    column :email
    column :sign_in_count
    column :last_seen
    actions
    column 'Action' do |user|
      link_to 'Impersonate', impersonate_admin_user_path(user), target: '_blank'
    end
  end

  filter :id
  filter :first_name
  filter :last_name
  filter :email
  filter :last_seen
  filter :sign_in_count

  form do |f|
    f.inputs 'User Details' do
      f.semantic_errors(*f.object.errors.keys)
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :marketing_consent
    end
    f.actions
  end
end

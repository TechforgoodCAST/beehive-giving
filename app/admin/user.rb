ActiveAdmin.register User do
  config.per_page = 10

  permit_params :agree_to_terms, :email, :first_name, :last_name,
                :marketing_consent, :organisation_id, :organisation_type,
                :password, :password_confirmation

    def scoped_collection
      User.includes(:organisation)
    end
  end

  member_action :impersonate do
    user = User.find(params[:id])
    cookies[:auth_token] = user.auth_token
    redirect_to root_path, notice: "Impersonating #{user.email}"
  end

  index do
    column :id
    column 'Organisation' do |user|
      if user.organisation
        link_to user.organisation.name, [:admin, user.organisation]
      end
    end
    column :authorised
    column :first_name
    column :last_name
    column :email
    column :organisation_type
    column :sign_in_count
    column :last_seen
    actions
    column 'Action' do |user|
      link_to 'Impersonate', impersonate_admin_user_path(user), target: '_blank'
    end
  end

  filter :id
  filter :organisation_type
  filter :first_name
  filter :last_name
  filter :email
  filter :last_seen
  filter :sign_in_count

  form do |f|
    f.inputs 'User Details' do
      f.semantic_errors *f.object.errors.keys
      f.input :organisation_id
      f.input :organisation_type, as: :select, collection: %w[Recipient Funder]
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :agree_to_terms
      f.input :marketing_consent
    end
    f.actions
  end
end

ActiveAdmin.register User do
  permit_params :first_name, :last_name, :org_type, :agree_to_terms,
                :email, :password, :password_confirmation, :role,
                :organisation_id

  controller do
    def scoped_collection
      User.includes(:organisation)
    end
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
    column :job_role
    column :role
    column :sign_in_count
    column :last_seen
    actions
  end

  filter :id
  filter :organisation, input_html: { class: 'chosen-select' }
  filter :role
  filter :first_name
  filter :last_name
  filter :job_role
  filter :email
  filter :last_seen
  filter :sign_in_count

  form do |f|
    f.inputs 'User Details' do
      f.input :organisation, required: true,
                             input_html: { class: 'chosen-select' }
      f.input :role
      f.input :org_type, as: :select, collection: Organisation::ORG_TYPE
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :agree_to_terms
    end
    f.actions
  end
end

ActiveAdmin.register Recipient do
  permit_params :name, :contact_number, :website, :street_address, :city,
                :region, :postal_code, :country, :charity_number,
                :company_number, :founded_on, :registered_on, :mission, :status,
                :registered, :active_on_beehive, organisation_ids: []

  controller do
    def find_resource
      Recipient.where(slug: params[:id]).first!
    end
  end

  filter :name
  filter :charity_number
  filter :company_number
  filter :country
  filter :registered
  filter :founded_on
  filter :created_at
  filter :recipient_funder_accesses_count, label: 'Unlocks'

  index do
    selectable_column
    column :name
    column :website
    column :country
    column :org_type
    column :street_address
    column :postal_code
    column :latitude
    column :longitude
    actions
  end

  show do
    tabs do
      tab 'Overview' do
        attributes_table do
          row :id
          row :name
          row :mission
          row :status
          row :founded_on
          row(:registered) { status_tag(recipient.registered) }
          row :registered_on
          row :contact_number
          row :website
          row :charity_number
          row :company_number
          row('Users') do |recipient|
            recipient.users.each do |user|
              li "#{user.email} | Authorised: #{user.authorised}"
            end
          end
        end
      end

      tab 'Address' do
        attributes_table do
          row :street_address
          row :city
          row :region
          row :postal_code
          row :country
        end
      end
    end
  end
end

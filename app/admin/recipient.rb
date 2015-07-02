ActiveAdmin.register Recipient do
  config.per_page = 50

  permit_params :name, :contact_number, :website,
  :street_address, :city, :region, :postal_code, :country, :charity_number,
  :company_number, :founded_on, :registered_on, :mission, :status, :registered, :active_on_beehive, organisation_ids: []

  controller do
    def find_resource
      Recipient.where(slug: params[:id]).first!
    end
  end

  filter :name
  filter :country
  filter :registered
  filter :founded_on
  filter :created_at

  index do
    selectable_column
    column "Organisation", :name do |recipient|
      link_to recipient.name, [:admin, recipient]
    end
    column :website
    column :contact_number
    column :country
    column ("Users"){|f| f.users.count }
    column ("Profiles"){|f| f.profiles.count }
    column ("Unlocks"){|f| RecipientFunderAccess.where(recipient_id: f.id).count }
    column ("Grants"){|f| f.grants.count }
    column ("Requests"){|f| f.features.count }
  end

  show do
    tabs do
      tab 'Overview' do
        attributes_table do
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

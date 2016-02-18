ActiveAdmin.register Recipient do

  permit_params :name, :contact_number, :website,
  :street_address, :city, :region, :postal_code, :country, :charity_number,
  :company_number, :founded_on, :registered_on, :mission, :status, :registered, :active_on_beehive, organisation_ids: []

  controller do
    def find_resource
      Recipient.where(slug: params[:id]).first!
    end

    def scoped_collection
      Recipient.includes(:users, :profiles, :grants, :features)
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
    column "Organisation", :name do |recipient|
      link_to recipient.name, [:admin, recipient]
    end
    column :website
    column :country
    column ("Users"){|f| f.users.count }
    column :org_type
    column ("Profiles"){|f| f.profiles.count }
    column ("Unlocks"), :recipient_funder_accesses_count
    column ("Unlocked Funders") do |r|
      r.recipient_funder_accesses.each do |f|
        li "#{Funder.find(f.funder_id).name} (#{Recipient.find(f.recipient_id).created_at.strftime("%d-%b")}) / (#{f.created_at.strftime("%d-%b")})"
      end
    end
    column ("Proposals"){|f| f.proposals.count }
    column ("Grants"){|f| f.grants.count }
    column ("Requests"){|f| f.features.count }
    column ("Scrape") do |r|
      if r.charity_name.present? && r.company_name.present?
        "Both"
      elsif r.charity_name.present? && !r.company_name.present?
        "Charity"
      elsif !r.charity_name.present? && r.company_name.present?
        "Company"
      else
        "None"
      end
    end
    column :street_address
    column :postal_code
    column :latitude
    column :longitude
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
              li "#{user.user_email} | Authorised: #{user.authorised}"
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

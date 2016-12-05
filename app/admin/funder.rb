ActiveAdmin.register Funder do
  config.sort_order = 'created_at_asc'

  permit_params :name, :contact_number, :website,
  :street_address, :city, :region, :postal_code, :country, :charity_number,
  :company_number, :founded_on, :registered_on, :mission, :status, :registered,
  :active_on_beehive, :slug, :org_type, organisation_ids: []

  controller do
    def find_resource
      Funder.where(slug: params[:id]).first!
    end

    def scoped_collection
      Funder.includes(:grants, :features)
    end
  end

  filter :name

  index do
    column 'Funder', :name do |funder|
      link_to funder.name, [:admin, funder]
    end
    column :active_on_beehive
    column('Profiles') {|f| f.profiles.count }
    column('Grants') {|f| f.grants.count }
    column('Requests') {|f| f.features.count }
    actions
  end
end

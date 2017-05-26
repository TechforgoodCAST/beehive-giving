ActiveAdmin.register Funder do
  config.sort_order = 'created_at_asc'

  permit_params :name, :contact_number, :website, :street_address, :city,
                :region, :postal_code, :country, :charity_number,
                :company_number, :founded_on, :registered_on, :mission, :status,
                :registered, :active_on_beehive, :slug, :org_type,
                :operating_for, :multi_national, :income, :employees,
                :volunteers, :skip_validation, organisation_ids: []

  controller do
    def find_resource
      Funder.where(slug: params[:id]).first!
    end
  end

  filter :name

  index do
    selectable_column
    column 'Funder', :name do |funder|
      link_to funder.name, [:admin, funder]
    end
    column :active_on_beehive
    actions
  end

  show do
    attributes_table do
      row :slug
      row :name
      row :website
      row :charity_number
      row :active_on_beehive
    end
  end

  form do |f|
    f.inputs do
      inputs 'Basics' do
        f.input :slug
        f.input :name
        f.input :website
        f.input :charity_number
        f.input :active_on_beehive, as: :boolean
        f.input :skip_validation, as: :boolean, input_html: { checked: 'checked' }
      end
    end
    f.actions
  end
end

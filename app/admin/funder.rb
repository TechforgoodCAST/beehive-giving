ActiveAdmin.register Funder do
  permit_params :active, :microsite, :name, :primary_color, :secondary_color,
                :slug, :website

  controller do
    def find_resource
      scoped_collection.where(slug: params[:id]).first!
    end
  end

  filter :name

  index do
    selectable_column
    column 'Funder', :name do |funder|
      link_to funder.name, [:admin, funder]
    end
    column :active
    column :microsite
    column :funds do |funder|
      funder.funds.size
    end
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :slug
      row :name
      row :website
      row :charity_number
      row :company_number
      row :active
      row :microsite
      row :primary_color
      row :secondary_color
      row :opportunities_last_updated_at
    end

    panel 'Funds' do
      table_for funder.funds do
        column :slug
        column :active
        column :microsite
        column :actions do |fund|
          link_to 'View', [:admin, fund]
          link_to 'Edit', [:edit_admin, fund]
        end
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :slug
      f.input :name
      f.input :active
      f.input :microsite
      f.input :primary_color, as: :string
      f.input :secondary_color, as: :string
    end
    f.actions
  end
end

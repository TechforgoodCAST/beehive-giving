ActiveAdmin.register Recipient do
  permit_params :category_name, :charity_number, :company_number, :country,
                :description, :district, :income_band_name, :name,
                :operating_for_name, :website

  controller do
    def scoped_collection
      end_of_association_chain.includes(:country)
    end

    def find_resource
      scoped_collection.find_by_hashid(params[:id])
    end
  end

  filter :name
  filter :category_code
  filter :created_at
  filter :updated_at

  index do
    selectable_column
    column :name
    column :category_name
    column :country
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :category_name
      row :description
      row :charity_number
      row :company_number
      row :country
      row :district
      row :income_band_name
      row :operating_for_name
      row :website
      row :user
    end
  end
end

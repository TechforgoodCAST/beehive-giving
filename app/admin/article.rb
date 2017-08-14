ActiveAdmin.register Article do
  permit_params :slug, :title, :body

  controller do
    def find_resource
      scoped_collection.find_by(slug: params[:id])
    end
  end

  index do
    column :slug
    column :title
    column :body
    actions
  end

  filter :slug
  filter :title

  form do |f|
    f.inputs do
      f.input :slug
      f.input :title
      f.input :body
    end
    f.actions
  end
end

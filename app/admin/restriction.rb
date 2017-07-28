ActiveAdmin.register Restriction do
  permit_params :restriction, :details, :invert, :category

  form do |f|
    f.inputs do
      f.input :details, label: 'Are you seeking funding for ___ ?'
      f.input :invert
      f.input :category, collection: %w(Proposal Organisation),
                         input_html: { class: 'chosen-select' }
    end
    f.actions
  end

  index do
    column :details
    column :invert
    column :category
    actions
  end
end

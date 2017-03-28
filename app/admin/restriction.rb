ActiveAdmin.register Restriction do
  permit_params :restriction, :details, :invert

  form do |f|
    f.inputs do
      f.input :details, label: 'Are you seeking funding for ___ ?'
      f.input :invert
    end
    f.actions
  end

  index do
    column :details
    column :invert
    actions
  end
end

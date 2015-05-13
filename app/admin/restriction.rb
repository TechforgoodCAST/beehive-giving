ActiveAdmin.register Restriction do
  config.sort_order = 'created_at_asc'
  config.per_page = 1000

  permit_params :restriction, :details, funder_ids: []

  form do |f|
    f.inputs do
      f.input :details, label: 'Are you seeking funding for ___ ?'
      f.input :funders, collection: Funder.order('name ASC'), input_html: {multiple: true, class: 'chosen-select'}, member_label: :name, label: 'Funders'
    end
    f.actions
  end

  index do
    column :details
    column("Funders") do |r|
      r.funders.each do |f|
        li f.name
      end
    end
    actions
  end

end

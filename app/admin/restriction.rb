ActiveAdmin.register Restriction do
  config.sort_order = 'created_at_asc'
  config.per_page = 1000

  permit_params :restriction, :details, :funding_stream, funder_ids: []

  form do |f|
    f.inputs do
      f.input :details, label: 'Are you seeking funding for ___ ?'
      f.input :funders, collection: Funder.order('name ASC'), input_html: {multiple: true, class: 'chosen-select'}, member_label: :name, label: 'Funders'
      f.input :funding_stream, collection: Grant.pluck(:funding_stream).uniq << 'All', input_html: {class: 'chosen-select'}
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
    column :funding_stream
    actions
  end

end

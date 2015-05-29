ActiveAdmin.register Restriction do
  config.sort_order = 'created_at_asc'
  config.per_page = 1000

  permit_params :restriction, :details

  form do |f|
    f.inputs do
      f.input :details, label: 'Are you seeking funding for ___ ?'
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
    column("Funding streams") do |r|
      r.funding_streams.each do |f|
        li f.label
      end
    end
    actions
  end

end

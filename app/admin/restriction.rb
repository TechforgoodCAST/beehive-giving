ActiveAdmin.register Restriction do

  config.per_page = 200

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
    column :invert
    actions
  end

end

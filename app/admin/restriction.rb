ActiveAdmin.register Restriction do
  config.sort_order = 'created_at_asc'
  config.per_page = 1000

  permit_params :funder_id, :restriction, :details

end

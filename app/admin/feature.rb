ActiveAdmin.register Feature do
  config.sort_order = 'created_at_asc'

  index do
    column :data_requested
    column "Size", :request_amount_awarded
    column "Duration", :request_funding_dates
    column "Location", :request_funding_countries
    column "for", :funder do |feature|
      link_to feature.funder.name, [:admin, feature.recipient]
    end
    column "by", :recipient do |feature|
      link_to feature.recipient.name, [:admin, feature.recipient]
    end
    column "at", :updated_at
    actions
  end
end

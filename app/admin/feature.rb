ActiveAdmin.register Feature do
  config.sort_order = 'created_at_asc'
  config.per_page = 1000

  index do
    column :data_requested
    column "Size", :request_amount_awarded
    column "Duration", :request_funding_dates
    column "Location", :request_funding_countries
    column "Grant count", :request_grant_count
    column "Application count", :request_applications_count
    column "Enquiry count", :request_enquiry_count
    column "Funding types", :request_funding_types
    column "Funding streams", :request_funding_streams
    column "Approval months", :request_approval_months
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

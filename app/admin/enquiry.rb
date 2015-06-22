ActiveAdmin.register Enquiry do

  config.sort_order = 'created_at_asc'
  config.per_page = 1000

  permit_params :recipient_id, :funder_id, :funding_stream

  index do
    selectable_column
    column "Recipient" do |enquiry|
      link_to enquiry.recipient.name, [:admin, enquiry.recipient]
    end
    column "Funder" do |enquiry|
      link_to enquiry.funder.name, [:admin, enquiry.funder]
    end
    column :approach_funder_count
    column :funding_stream
    actions
  end

end

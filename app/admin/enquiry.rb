ActiveAdmin.register Enquiry do

  config.sort_order = 'created_at_asc'
  config.per_page = 1000

  index do
    selectable_column
    column "Recipient" do |enquiry|
      link_to enquiry.recipient.name, [:admin, enquiry.recipient]
    end
    column "Funder" do |enquiry|
      link_to enquiry.funder.name, [:admin, enquiry.funder]
    end
    column :approach_funder_count
    column :guidance_count
    column :apply_count
    actions
  end

end

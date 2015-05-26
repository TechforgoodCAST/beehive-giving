ActiveAdmin.register RecipientAttribute do
  config.sort_order = 'created_at_asc'

  permit_params :recipient, :problem, :solution

  index do
    selectable_column
    column "Recipient" do |attribute|
      link_to attribute.recipient.name, [:admin, attribute.recipient]
    end
    column :problem
    column :solution
    actions
  end

  filter :recipient, input_html: {class: 'chosen-select'}
  filter :problem
  filter :solution
  filter :created_at
  filter :updated_at

end

ActiveAdmin.register Recommendation do

  permit_params :recipient_id, :funder_id, :score

  index do
    selectable_column
    column :recipient
    column :funder
    column :score
    actions
  end

  filter :funder, input_html: {class: 'chosen-select'}
  filter :recipient, input_html: {class: 'chosen-select'}
  filter :score
  filter :created_at
  filter :updated_at

end

ActiveAdmin.register Recommendation do

  permit_params :recipient_id, :funder_id, :score

  index do
    selectable_column
    column :recipient
    column :funder
    column :score
    column :recommendation_quality
    actions
  end

  filter :funder, input_html: {class: 'chosen-select'}
  filter :recipient, input_html: {class: 'chosen-select'}
  filter :score
  filter :recommendation_quality, as: :select, collection: Recommendation::RECOMMENDATION_QUALITY
  filter :updated_at

end

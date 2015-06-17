ActiveAdmin.register Recommendation do

  permit_params :recipient_id, :funder_id, :score

  index do
    selectable_column
    column :recipient
    column :funder
    column :score
    actions
  end

end

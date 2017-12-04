ActiveAdmin.register Criterion do
  permit_params :priority, :details, :invert, :category

  filter :details
  filter :funds, input_html: { class: 'chosen-select' }
  filter :category, as: :select, collection: %w[Proposal Recipient]
  filter :type, as: :select, collection: %w[Restriction Priority]

  form do |f|
    f.inputs do
      f.input :details, label: 'Are you seeking funding for ___ ?'
      f.input :invert
      f.input :category, collection: %w[Proposal Recipient],
                         input_html: { class: 'chosen-select' }
    end
    f.actions
  end

  show do
    attributes_table do
      row :details
      row :invert
      row :category
    end
    panel 'Funds with this priority' do
      table_for funds do
        column :slug
        column :funder
        column :name
        column :actions do |fund|
          link_to 'View', [:admin, fund]
          link_to 'Edit', [:edit_admin, fund]
        end
      end
    end
  end

  index do
    selectable_column
    column :type
    column :details
    column :invert
    column :category
    column :funds do |r|
      r.funds.count
    end
    actions
  end

  csv do
    column :type
    column :details
    column :invert
    column :category
    column :funds do |r|
      r.funds.count
    end
  end
end

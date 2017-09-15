ActiveAdmin.register Restriction do
  permit_params :restriction, :details, :invert, :category

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
    panel 'Funds with this restriction' do
      table_for restriction.funds do
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
    column :details
    column :invert
    column :category
    column :funds do |r|
      r.funds.count
    end
    actions
  end

  csv do
    column :details
    column :invert
    column :category
    column :funds do |r|
      r.funds.count
    end
  end
end

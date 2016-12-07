ActiveAdmin.register Grant do

  permit_params :funding_stream, :grant_type, :attention_how, :amount_awarded,
  :amount_applied, :installments, :approved_on, :start_on, :end_on, :attention_on, :applied_on,
  :recipient_id, :funder_id, :days_from_start_to_end, :open_call,
  country_ids: [], district_ids: []

  controller do
    def scoped_collection
      Grant.includes(:funder, :recipient)
    end
  end

  index do
    selectable_column
    column 'Organisation', :recipient do |grant|
      link_to grant.recipient.name, [:admin, grant.recipient] if grant.recipient
    end
    column 'Funder', :funder do |grant|
      link_to grant.funder.name, [:admin, grant.funder] if grant.funder
    end
    column :amount_awarded
    actions
  end

  filter :funder, input_html: { class: 'chosen-select' }
  filter :recipient, input_html: { class: 'chosen-select' }
  filter :created_at
  filter :updated_at

  show do
    attributes_table do
      row 'Funder', :funder do |grant|
        if grant.recipient
          link_to grant.recipient.name, [:admin, grant.recipient]
        end
      end
      row 'Recipient', :recipient do |grant|
        link_to grant.funder.name, [:admin, grant.funder] if grant.funder
      end
      row :funding_stream
      row :grant_type
      row :installments
      row :amount_awarded
      row :amount_applied
      row :attention_how
      row :attention_on
      row :applied_on
      row :approved_on
      row :start_on
      row :end_on
      row(:open_call) { status_tag(grant.open_call) }
      row :countries do |grant|
        grant.countries.each do |c|
          li c.name
        end
      end
      row :districts do |grant|
        grant.districts.each do |d|
          li d.district
        end
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :funder, required: true
      f.input :recipient, required: true
      f.input :funding_stream, collection: Grant::FUNDING_STREAM.map { |label| label }
      f.input :grant_type, collection: Grant::GRANT_TYPE.map { |label| label }
      f.input :installments
      f.input :amount_awarded
      f.input :amount_applied
      f.input :attention_how, collection: Grant::ATTENTION_HOW.map { |label| label }
      f.input :attention_on
      f.input :applied_on
      f.input :approved_on
      f.input :start_on
      f.input :end_on
      f.input :countries, collection: Country.order('name ASC'), input_html: { multiple: true, class: 'chosen-select' }, member_label: :name
      f.input :districts, collection: District.order('label ASC'), input_html: { multiple: true, class: 'chosen-select' }, member_label: :label
    end
    f.actions
  end

end

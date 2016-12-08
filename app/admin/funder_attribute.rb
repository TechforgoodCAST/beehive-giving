# TODO: deprecated
ActiveAdmin.register FunderAttribute do
  permit_params :funder_id, :year, :grant_count, :application_count, :description,
  :enquiry_count, :funding_stream, :funding_size_average, :funding_size_min,
  :funding_size_max, :funding_duration_average, :funding_duration_min,
  :funding_duration_max, :funded_average_age, :funded_average_income,
  :funded_average_paid_staff, :beneficiary_min_age, :beneficiary_max_age,
  :funded_age_temp, :funded_income_temp, :application_link, :soft_restrictions,
  :application_details, country_ids: [], district_ids: [], approval_month_ids: [],
  funding_type_ids: [], beneficiary_ids: [], age_group_ids: []

  controller do
    def scoped_collection
      FunderAttribute.includes(:funder)
    end
  end

  index do
    selectable_column
    column :year
    column 'Funder' do |attribute|
      link_to attribute.funder.name, [:admin, attribute.funder]
    end
    column :funding_stream
    column :grant_count
    column :application_count
    column :enquiry_count
    actions
  end

  filter :funder, input_html: { class: 'chosen-select' }
  filter :year, as: :select, collection: Profile::VALID_YEARS
  filter :funding_stream
  filter :updated_at

  show do
    attributes_table do
      row :year
      row 'Funder', &:funder
      row :funding_stream
      row :description
      row :grant_count
      row :application_count
      row :enquiry_count
      row 'Approval month(s)' do |attribute|
        attribute.approval_months.each do |t|
          li t.month
        end
      end
      row 'Funding type(s)' do |attribute|
        attribute.funding_types.each do |t|
          li t.label
        end
      end
      row :application_link
      row :soft_restrictions
      row :application_details
      row :funding_size_average
      row :funding_size_min
      row :funding_size_max
      row :funding_duration_average
      row :funding_duration_min
      row :funding_duration_max
      row :funded_average_age
      row :funded_average_income
      row :funded_average_paid_staff
      row :age_groups do |attribute|
        attribute.age_groups.each do |a|
          li a.label
        end
      end
      row :funded_age_temp
      row :funded_income_temp
      row :beneficiaries do |attribute|
        attribute.beneficiaries.each do |b|
          li b.label
        end
      end
      row :countries do |attribute|
        attribute.countries.count
      end
      row :districts do |attribute|
        attribute.districts.count
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :year, as: :select, collection: Profile::VALID_YEARS
      f.input :funder, input_html: { class: 'chosen-select' }
      f.input :funding_stream, collection: Grant.uniq.pluck(:funding_stream) << 'All', input_html: { class: 'chosen-select' }
      f.input :description
      f.input :countries, as: :select, input_html: { multiple: true, class: 'chosen-select' }, member_label: :name, label: 'Countries'
      f.input :districts, as: :select, input_html: { multiple: true, class: 'chosen-select' }, member_label: :label, label: 'Districts'
      f.input :soft_restrictions
      f.input :application_details
      f.input :application_link
      f.input :grant_count
      f.input :application_count
      f.input :enquiry_count
      f.input :approval_months, as: :select, input_html: { multiple: true, class: 'chosen-select' }, member_label: :month, label: 'Approval Month(s)'
      f.input :funding_types, as: :select, input_html: { multiple: true, class: 'chosen-select' }, member_label: :label, label: 'Funding Type(s)'
      f.input :funding_size_average
      f.input :funding_size_min
      f.input :funding_size_max
      f.input :funding_duration_average
      f.input :funding_duration_min
      f.input :funding_duration_max
      f.input :funded_average_age
      f.input :funded_age_temp
      f.input :funded_average_income
      f.input :funded_income_temp
      f.input :funded_average_paid_staff
      f.input :beneficiaries, as: :select, input_html: { multiple: true, class: 'chosen-select' }, member_label: :label, label: 'Beneficiaries'
      f.input :beneficiary_min_age
      f.input :beneficiary_max_age
      f.input :age_groups, as: :select, input_html: { multiple: true, class: 'chosen-select' }, member_label: :label, label: 'Age Groups'
    end
    f.actions
  end
end

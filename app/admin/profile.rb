# TODO: deprecated
ActiveAdmin.register Profile do
  permit_params :organisation_id, :year, :gender, :min_age, :max_age,
                :income, :expenditure, :volunteer_count, :staff_count, :does_sell,
                :beneficiaries_count, :beneficiaries_count_actual, :income_actual,
                :expenditure_actual, beneficiary_ids: [], country_ids: [], district_ids: [],
                                     implementation_ids: [], implementor_ids: []

  controller do
    def scoped_collection
      Profile.includes(:organisation, :districts)
    end
  end

  index do
    column 'Organisation' do |profile|
      link_to profile.organisation.name, [:admin, profile]
    end
    column 'Locations', :districts do |profile|
      profile.districts.each do |d|
        li d.label
      end
    end
    column 'Organisation Age' do |user|
      if user.organisation.founded_on
        "#{((Date.today - user.organisation.founded_on).to_f / 356).round(1)} years"
      end
    end
    column :income do |profile|
      number_to_currency(profile.income, unit: '£', precision: 0)
    end
    column :income_actual
    column :staff_count
    column :volunteer_count
    column 'Beneficiaries', :beneficiaries do |profile|
      profile.beneficiaries.each do |b|
        li b.label
      end
    end
    column :gender
    column :min_age
    column :max_age
    column :created_at
  end

  filter :organisation
  filter :year, as: :select
  filter :countries, label: 'Country', member_label: :name
  filter :districts, label: 'District', member_label: :label, input_html: { multiple: true, class: 'chosen-select' }
  filter :income
  filter :created_at

  show do
    attributes_table do
      row('Year of profile', &:year)
      row 'Organisation' do |user|
        link_to user.organisation.name, [:admin, user.organisation]
      end
      row 'In which countries does your organisation benefit people?' do |profile|
        profile.countries.each do |c|
          li c.name
        end
      end
      row 'In which districts does your organisation benefit people?' do |profile|
        profile.districts.each do |d|
          li d.label
        end
      end
      row 'Who/what does your organisation target?' do |profile|
        profile.beneficiaries.each do |b|
          li b.label
        end
      end
      row 'Which gender does your organisation target?', &:gender
      row 'Min. age targeted', &:min_age
      row 'Max. age targeted', &:max_age
      row :staff_count
      row :volunteer_count
      row 'Who delivers your work?' do |profile|
        profile.implementors.each do |i|
          li i.label
        end
      end
      row 'Implementation approach' do |profile|
        profile.implementations.each do |i|
          li i.label
        end
      end
      row 'Do you recieve financial payment for your work?', &:does_sell
      row 'Beneficiaries impacted', &:beneficiaries_count
      row :beneficiaries_count_actual, &:beneficiaries_count_actual
      row :income do |profile|
        number_to_currency(profile.income, unit: '£', precision: 0)
      end
      row(:income_actual) { status_tag(profile.income_actual) }
      row :expenditure do |profile|
        number_to_currency(profile.expenditure, unit: '£', precision: 0)
      end
      row(:expenditure_actual) { status_tag(profile.expenditure_actual) }
      row 'Age from founding (years)' do |user|
        if user.organisation.founded_on
          ((Date.today - user.organisation.founded_on).to_f / 356).round(1)
        end
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :organisation
      f.input :year, as: :select, collection: Profile::VALID_YEARS.map { |label| label }
      f.input :countries, collection: Country.order('name ASC'), input_html: { multiple: true, class: 'chosen-select' }, member_label: :name, label: 'In which countries does your organisation benefit people?'
      f.input :districts, collection: District.order('label ASC'), input_html: { multiple: true, class: 'chosen-select' }, member_label: :label, label: 'In which districts does your organisation benefit people?'
      f.input :beneficiaries, collection: Beneficiary.order('label ASC'), input_html: { multiple: true, class: 'chosen-select' }, member_label: :label, label: 'Who/what does your organisation target?'
      f.input :gender, collection: Profile::GENDERS.map { |label| label }
      f.input :min_age
      f.input :max_age
      f.input :volunteer_count
      f.input :staff_count
      f.input :implementors, collection: Implementor.order('label ASC'), input_html: { multiple: true, class: 'chosen-select' }, member_label: :label, label: 'Who delivers your work?'
      f.input :implementations, collection: Implementation.order('label ASC'), input_html: { multiple: true, class: 'chosen-select' }, member_label: :label, label: 'How fo you implement your work?'
      f.input :does_sell, label: 'Do you recieve financial payment for your work?'
      f.input :beneficiaries_count
      f.input :beneficiaries_count_actual
      f.input :income
      f.input :income_actual
      f.input :expenditure
      f.input :expenditure_actual
    end
    f.actions
  end
end

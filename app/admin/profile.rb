ActiveAdmin.register Profile do
  config.sort_order = 'created_at_asc'

  permit_params :organisation_id, :year, :gender, :currency, :goods_services, :who_pays,
  :who_buys, :min_age, :max_age, :income, :income_actual, :expenditure, :expenditure_actual,
  :volunteer_count, :staff_count, :job_role_count, :department_count, :goods_count,
  :beneficiaries_count, :beneficiaries_count_actual, :units_count, :units_count_actual,
  :who_pays, :services_count,
  beneficiary_ids: [], country_ids: [],district_ids: [],implementation_ids: []

  index do
    column "Organisation" do |profile|
      link_to profile.organisation.name, [:admin, profile]
    end
    column "Year of profile", :year
    column "Locations", :districts do |profile|
      profile.districts.each do |d|
        li d.label
      end
    end
    column "Age (years)" do |user|
      if user.organisation.founded_on
        ((Date.today - user.organisation.founded_on).to_f / 356).round(1)
      end
    end
    column :income do |profile|
      number_to_currency(profile.income, unit: '£', precision: 0)
    end
    column :income_actual
    column :created_at
  end

  filter :organisation
  filter :districts, label: "Location", member_label: :label
  filter :income
  filter :created_at

  show do
    attributes_table do
      row("Year of profile") { |profile| profile.year }
      row "Organisation" do |user|
        link_to user.organisation.name, [:admin, user.organisation]
      end
      row "Locations" do |profile|
        profile.districts.each do |d|
          li d.label
        end
      end
      row "Age (years)" do |user|
        if user.organisation.founded_on
          ((Date.today - user.organisation.founded_on).to_f / 356).round(1)
        end
      end
      row :currency
      row :income do |profile|
        number_to_currency(profile.income, unit: '£', precision: 0)
      end
      row :income_actual
      row :expenditure do |profile|
        number_to_currency(profile.expenditure, unit: '£', precision: 0)
      end
      row :expenditure_actual
      row "Beneficiary focus" do |profile|
        profile.beneficiaries.each do |b|
          li b.label
        end
      end
      row("Min. age targeted") { |profile| profile.min_age }
      row("Max. age targeted") { |profile| profile.max_age }
      row("Gender focus") { |profile| profile.gender }
      row :staff_count
      row :volunteer_count
      row "Implementation approach" do |profile|
        profile.implementations.each do |i|
          li i.label
        end
      end
      row("Delivery focus") { |profile| profile.goods_services }
      row("Sales focus") { |profile| profile.who_pays }
      row("Beneficiaries impacted") { |profile| profile.beneficiaries_count }
      row :benediciaties_count_actual
      row("Units deliverd") { |profile| profile.units_count }
      row :units_count_actual
    end
  end

  form do |f|
    f.inputs do
      f.input :organisation
      f.input :year, as: :select, collection: Profile::VALID_YEARS.map { |label| label }
      f.input :districts, as: :select, :input_html => {:multiple => true}, member_label: :label, label: 'Where does your organisation benefit people?'
      f.input :beneficiaries, as: :select, :input_html => {:multiple => true}, member_label: :label, label: 'Who does your organisation target?'
      f.input :gender, collection: Profile::GENDERS.map { |label| label }
      f.input :min_age
      f.input :max_age
      f.input :volunteer_count
      f.input :staff_count
      f.input :department_count
      f.input :job_role_count
      f.input :currency, collection: Profile::CURRENCY.map { |label| label }
      f.input :income
      f.input :income_actual
      f.input :expenditure
      f.input :expenditure_actual
      f.input :implementations, as: :select, :input_html => {:multiple => true}, member_label: :label, label: 'How fo you implement your work?'
      f.input :goods_services, collection: Profile::GOODS_SERVICES.map { |label| label }
      f.input :services_count
      f.input :goods_count
      f.input :who_pays, collection: Profile::WHO_PAYS.map { |label| label }
      f.input :beneficiaries_count
      f.input :beneficiaries_count_actual
      f.input :units_count
      f.input :units_count_actual
    end
    f.actions
  end

end

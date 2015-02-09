ActiveAdmin.register Profile do
  config.sort_order = 'created_at_asc'

  permit_params :year, :gender, :currency, :goods_services, :who_pays, :who_buys,
  :min_age, :max_age, :income, :expenditure, :volunteer_count,
  :staff_count, :job_role_count, :department_count, :goods_count,
  :who_pays, :services_count, beneficiary_ids: [], country_ids: [], district_ids: [], implementation_ids: []

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
      ((Date.today - user.organisation.founded_on).to_f / 356).round(1)
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
        ((Date.today - user.organisation.founded_on).to_f / 356).round(1)
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

end

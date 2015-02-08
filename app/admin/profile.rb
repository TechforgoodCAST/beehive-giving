ActiveAdmin.register Profile do
  permit_params :year, :gender, :currency, :goods_services, :who_pays, :who_buys,
  :min_age, :max_age, :income, :expenditure, :volunteer_count,
  :staff_count, :job_role_count, :department_count, :goods_count,
  :who_pays, :services_count, beneficiary_ids: [], country_ids: [], district_ids: [], implementation_ids: []

  index do
    column "Organisation", :organisation do |profile|
      link_to profile.organisation.name, [:admin, profile.organisation]
    end
    column "Organisation type", :organisation do |profile|
      profile.organisation.type
    end
    column "Profile year", :year
    actions
  end
end

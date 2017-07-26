# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170725164415) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "intarray"

  create_table "active_admin_comments", id: :serial, force: :cascade do |t|
    t.string "namespace", limit: 255
    t.text "body"
    t.string "resource_id", limit: 255, null: false
    t.string "resource_type", limit: 255, null: false
    t.integer "author_id"
    t.string "author_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "admin_users", id: :serial, force: :cascade do |t|
    t.string "email", limit: 255, default: "", null: false
    t.string "encrypted_password", limit: 255, default: "", null: false
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "age_groups", id: :serial, force: :cascade do |t|
    t.string "label"
    t.integer "age_from"
    t.integer "age_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "age_groups_profiles", id: :serial, force: :cascade do |t|
    t.integer "age_group_id"
    t.integer "profile_id"
    t.index ["age_group_id", "profile_id"], name: "index_age_groups_profiles_on_age_group_id_and_profile_id"
  end

  create_table "age_groups_proposals", id: :serial, force: :cascade do |t|
    t.integer "age_group_id"
    t.integer "proposal_id"
    t.index ["age_group_id", "proposal_id"], name: "index_age_groups_proposals_on_age_group_id_and_proposal_id"
  end

  create_table "articles", id: :serial, force: :cascade do |t|
    t.string "title", null: false
    t.string "slug", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_articles_on_slug", unique: true
  end

  create_table "beneficiaries", id: :serial, force: :cascade do |t|
    t.string "label", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category"
    t.string "sort"
  end

  create_table "beneficiaries_profiles", id: :serial, force: :cascade do |t|
    t.integer "beneficiary_id"
    t.integer "profile_id"
    t.index ["beneficiary_id", "profile_id"], name: "index_beneficiaries_profiles_on_beneficiary_id_and_profile_id"
    t.index ["beneficiary_id"], name: "index_beneficiaries_profiles_on_beneficiary_id"
    t.index ["profile_id"], name: "index_beneficiaries_profiles_on_profile_id"
  end

  create_table "beneficiaries_proposals", id: :serial, force: :cascade do |t|
    t.integer "beneficiary_id"
    t.integer "proposal_id"
    t.index ["beneficiary_id"], name: "index_beneficiaries_proposals_on_beneficiary_id"
    t.index ["proposal_id"], name: "index_beneficiaries_proposals_on_proposal_id"
  end

  create_table "countries", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "alpha2", limit: 255
    t.integer "priority", default: 0
    t.index ["name", "alpha2"], name: "index_countries_on_name_and_alpha2", unique: true
  end

  create_table "countries_funds", id: :serial, force: :cascade do |t|
    t.integer "country_id"
    t.integer "fund_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_countries_funds_on_country_id"
    t.index ["fund_id"], name: "index_countries_funds_on_fund_id"
  end

  create_table "countries_profiles", id: :serial, force: :cascade do |t|
    t.integer "country_id"
    t.integer "profile_id"
    t.index ["country_id", "profile_id"], name: "index_countries_profiles_on_country_id_and_profile_id"
    t.index ["country_id"], name: "index_countries_profiles_on_country_id"
    t.index ["profile_id"], name: "index_countries_profiles_on_profile_id"
  end

  create_table "countries_proposals", id: :serial, force: :cascade do |t|
    t.integer "country_id"
    t.integer "proposal_id"
    t.index ["country_id"], name: "index_countries_proposals_on_country_id"
    t.index ["proposal_id"], name: "index_countries_proposals_on_proposal_id"
  end

  create_table "districts", id: :serial, force: :cascade do |t|
    t.integer "country_id"
    t.string "name", limit: 255
    t.string "subdivision", limit: 255
    t.string "region"
    t.string "sub_country"
    t.string "slug"
    t.index ["country_id"], name: "index_districts_on_country_id"
  end

  create_table "districts_funds", id: :serial, force: :cascade do |t|
    t.integer "district_id"
    t.integer "fund_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["district_id"], name: "index_districts_funds_on_district_id"
    t.index ["fund_id"], name: "index_districts_funds_on_fund_id"
  end

  create_table "districts_profiles", id: :serial, force: :cascade do |t|
    t.integer "district_id"
    t.integer "profile_id"
    t.index ["district_id", "profile_id"], name: "index_districts_profiles_on_district_id_and_profile_id"
    t.index ["district_id"], name: "index_districts_profiles_on_district_id"
    t.index ["profile_id"], name: "index_districts_profiles_on_profile_id"
  end

  create_table "districts_proposals", id: :serial, force: :cascade do |t|
    t.integer "district_id"
    t.integer "proposal_id"
    t.index ["district_id"], name: "index_districts_proposals_on_district_id"
    t.index ["proposal_id"], name: "index_districts_proposals_on_proposal_id"
  end

  create_table "eligibilities", id: :serial, force: :cascade do |t|
    t.integer "category_id", null: false
    t.integer "restriction_id", null: false
    t.boolean "eligible", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category_type", default: "Proposal", null: false
    t.index ["category_id"], name: "index_eligibilities_on_category_id"
    t.index ["category_type"], name: "index_eligibilities_on_category_type"
    t.index ["restriction_id"], name: "index_eligibilities_on_restriction_id"
  end

  create_table "enquiries", id: :serial, force: :cascade do |t|
    t.integer "recipient_id"
    t.integer "funder_id"
    t.boolean "new_project"
    t.boolean "new_location"
    t.integer "amount_seeking"
    t.integer "duration_seeking"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "approach_funder_count", default: 0
    t.string "funding_stream"
    t.integer "fund_id"
    t.integer "proposal_id"
    t.index ["fund_id"], name: "index_enquiries_on_fund_id"
    t.index ["funder_id"], name: "index_enquiries_on_funder_id"
    t.index ["proposal_id"], name: "index_enquiries_on_proposal_id"
    t.index ["recipient_id"], name: "index_enquiries_on_recipient_id"
  end

  create_table "features", id: :serial, force: :cascade do |t|
    t.integer "funder_id"
    t.integer "recipient_id"
    t.boolean "data_requested"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "request_amount_awarded"
    t.boolean "request_funding_dates"
    t.boolean "request_funding_countries"
    t.boolean "request_grant_count"
    t.boolean "request_applications_count"
    t.boolean "request_enquiry_count"
    t.boolean "request_funding_types"
    t.boolean "request_funding_streams"
    t.boolean "request_approval_months"
    t.index ["funder_id"], name: "index_features_on_funder_id"
    t.index ["recipient_id"], name: "index_features_on_recipient_id"
  end

  create_table "feedbacks", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "nps"
    t.integer "taken_away"
    t.integer "informs_decision"
    t.text "other"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "application_frequency"
    t.string "grant_frequency"
    t.string "marketing_frequency"
    t.integer "price"
    t.string "most_useful"
    t.integer "suitable"
    t.index ["user_id"], name: "index_feedbacks_on_user_id"
  end

  create_table "funds", id: :serial, force: :cascade do |t|
    t.integer "funder_id"
    t.string "type_of_fund"
    t.string "name"
    t.text "description"
    t.string "slug"
    t.boolean "open_call"
    t.boolean "active"
    t.text "key_criteria"
    t.string "currency"
    t.string "application_link"
    t.boolean "geographic_scale_limited"
    t.boolean "restrictions_known"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "open_data", default: false
    t.date "period_start"
    t.date "period_end"
    t.integer "grant_count"
    t.jsonb "amount_awarded_distribution", default: {}, null: false
    t.jsonb "award_month_distribution", default: {}, null: false
    t.jsonb "org_type_distribution", default: {}, null: false
    t.jsonb "income_distribution", default: {}, null: false
    t.jsonb "country_distribution", default: {}, null: false
    t.jsonb "tags", default: [], null: false
    t.jsonb "restriction_ids", default: [], null: false
    t.jsonb "sources", default: {}, null: false
    t.boolean "national", default: false, null: false
    t.decimal "amount_awarded_sum"
    t.jsonb "beneficiary_distribution", default: {}, null: false
    t.jsonb "grant_examples", default: [], null: false
    t.boolean "min_amount_awarded_limited", default: false
    t.integer "min_amount_awarded"
    t.boolean "max_amount_awarded_limited", default: false
    t.integer "max_amount_awarded"
    t.boolean "min_duration_awarded_limited", default: false
    t.integer "min_duration_awarded"
    t.boolean "max_duration_awarded_limited", default: false
    t.integer "max_duration_awarded"
    t.jsonb "permitted_costs", default: [], null: false
    t.jsonb "permitted_org_types", default: [], null: false
    t.index ["funder_id"], name: "index_funds_on_funder_id"
    t.index ["slug"], name: "index_funds_on_slug"
    t.index ["tags"], name: "index_funds_on_tags", using: :gin
  end

  create_table "funds_restrictions", id: :serial, force: :cascade do |t|
    t.integer "fund_id"
    t.integer "restriction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fund_id"], name: "index_funds_restrictions_on_fund_id"
    t.index ["restriction_id"], name: "index_funds_restrictions_on_restriction_id"
  end

  create_table "implementations", id: :serial, force: :cascade do |t|
    t.string "label", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "implementations_profiles", id: :serial, force: :cascade do |t|
    t.integer "implementation_id"
    t.integer "profile_id"
    t.index ["implementation_id", "profile_id"], name: "index_implementations_profiles"
    t.index ["implementation_id"], name: "index_implementations_profiles_on_implementation_id"
    t.index ["profile_id"], name: "index_implementations_profiles_on_profile_id"
  end

  create_table "implementations_proposals", id: :serial, force: :cascade do |t|
    t.integer "implementation_id"
    t.integer "proposal_id"
    t.index ["implementation_id", "proposal_id"], name: "index_implementations_proposals"
  end

  create_table "implementors", id: :serial, force: :cascade do |t|
    t.string "label", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "implementors_profiles", id: :serial, force: :cascade do |t|
    t.integer "implementor_id"
    t.integer "profile_id"
    t.index ["implementor_id", "profile_id"], name: "index_implementors_profiles_on_implementor_id_and_profile_id"
    t.index ["implementor_id"], name: "index_implementors_profiles_on_implementor_id"
    t.index ["profile_id"], name: "index_implementors_profiles_on_profile_id"
  end

  create_table "organisations", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "contact_number", limit: 255
    t.string "website", limit: 255
    t.string "street_address", limit: 255
    t.string "city", limit: 255
    t.string "region", limit: 255
    t.string "postal_code", limit: 255
    t.string "country", limit: 255
    t.string "charity_number", limit: 255
    t.string "company_number", limit: 255
    t.string "slug", limit: 255
    t.string "type", limit: 255
    t.text "mission"
    t.string "status", limit: 255, default: "Active - currently operational"
    t.date "founded_on"
    t.date "registered_on"
    t.boolean "registered"
    t.boolean "active_on_beehive"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "recipient_funder_accesses_count"
    t.integer "org_type"
    t.float "latitude"
    t.float "longitude"
    t.string "contact_email"
    t.string "charity_name"
    t.string "charity_status"
    t.float "charity_income"
    t.float "charity_spending"
    t.string "charity_recent_accounts_link"
    t.string "charity_trustees"
    t.string "charity_employees"
    t.string "charity_volunteers"
    t.string "charity_year_ending"
    t.string "charity_days_overdue"
    t.string "charity_registered_date"
    t.string "company_name"
    t.string "company_type"
    t.string "company_status"
    t.date "company_incorporated_date"
    t.date "company_last_accounts_date"
    t.date "company_next_accounts_date"
    t.date "company_next_returns_date"
    t.date "company_last_returns_date"
    t.text "company_sic", array: true
    t.string "company_recent_accounts_link"
    t.integer "grants_count", default: 0
    t.integer "operating_for"
    t.boolean "multi_national"
    t.integer "income"
    t.integer "employees"
    t.integer "volunteers"
    t.integer "funds_checked", default: 0, null: false
    t.index ["id", "type"], name: "index_organisations_on_id_and_type"
    t.index ["slug"], name: "index_organisations_on_slug", unique: true
  end

  create_table "profiles", id: :serial, force: :cascade do |t|
    t.integer "organisation_id"
    t.string "gender", limit: 255
    t.string "currency", limit: 255
    t.integer "year"
    t.integer "min_age"
    t.integer "max_age"
    t.integer "income"
    t.integer "expenditure"
    t.integer "volunteer_count"
    t.integer "staff_count"
    t.integer "job_role_count"
    t.integer "department_count"
    t.integer "goods_count"
    t.integer "units_count"
    t.integer "services_count"
    t.integer "beneficiaries_count"
    t.boolean "income_actual"
    t.boolean "expenditure_actual"
    t.boolean "beneficiaries_count_actual"
    t.boolean "units_count_actual"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "does_sell"
    t.integer "trustee_count"
    t.string "state"
    t.boolean "beneficiaries_other_required"
    t.string "beneficiaries_other"
    t.boolean "implementors_other_required"
    t.string "implementors_other"
    t.boolean "implementations_other_required"
    t.string "implementations_other"
    t.boolean "affect_people"
    t.boolean "affect_other"
    t.index ["organisation_id"], name: "index_profiles_on_organisation_id"
    t.index ["state"], name: "index_profiles_on_state"
  end

  create_table "proposals", id: :serial, force: :cascade do |t|
    t.integer "recipient_id"
    t.string "title"
    t.string "tagline"
    t.string "gender"
    t.string "outcome1"
    t.string "outcome2"
    t.string "outcome3"
    t.string "outcome4"
    t.string "outcome5"
    t.string "beneficiaries_other"
    t.integer "min_age"
    t.integer "max_age"
    t.integer "beneficiaries_count"
    t.integer "funding_duration"
    t.float "activity_costs"
    t.float "people_costs"
    t.float "capital_costs"
    t.float "other_costs"
    t.float "total_costs"
    t.boolean "activity_costs_estimated", default: false
    t.boolean "people_costs_estimated", default: false
    t.boolean "capital_costs_estimated", default: false
    t.boolean "other_costs_estimated", default: false
    t.boolean "all_funding_required"
    t.boolean "beneficiaries_other_required"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type_of_support"
    t.string "state", default: "initial"
    t.boolean "affect_people"
    t.boolean "affect_other"
    t.integer "affect_geo"
    t.boolean "total_costs_estimated", default: false
    t.boolean "private"
    t.boolean "implementations_other_required"
    t.string "implementations_other"
    t.jsonb "recommended_funds", default: []
    t.jsonb "eligibility", default: {}, null: false
    t.jsonb "recommendation", default: {}, null: false
    t.integer "funding_type"
    t.index ["recipient_id"], name: "index_proposals_on_recipient_id"
    t.index ["state"], name: "index_proposals_on_state"
  end

  create_table "recipient_funder_accesses", id: :serial, force: :cascade do |t|
    t.integer "recipient_id"
    t.integer "funder_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recommendations", id: :serial, force: :cascade do |t|
    t.integer "funder_id"
    t.integer "recipient_id"
    t.float "score", default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "recommendation_quality"
    t.string "eligibility"
    t.float "grant_amount_recommendation", default: 0.0
    t.float "grant_duration_recommendation", default: 0.0
    t.float "total_recommendation", default: 0.0
    t.float "org_type_score"
    t.float "beneficiary_score"
    t.float "location_score"
    t.integer "proposal_id"
    t.integer "fund_id"
    t.string "fund_slug"
    t.index ["funder_id"], name: "index_recommendations_on_funder_id"
    t.index ["proposal_id", "fund_id"], name: "index_recommendations_on_proposal_id_and_fund_id", unique: true
    t.index ["proposal_id", "fund_slug"], name: "index_recommendations_on_proposal_id_and_fund_slug", unique: true
    t.index ["recipient_id"], name: "index_recommendations_on_recipient_id"
  end

  create_table "restrictions", id: :serial, force: :cascade do |t|
    t.string "details", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "invert", default: false, null: false
    t.string "category", default: "Proposal", null: false
    t.boolean "has_condition", default: false, null: false
    t.string "condition"
  end

  create_table "subscriptions", id: :serial, force: :cascade do |t|
    t.integer "organisation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "stripe_user_id"
    t.boolean "active", default: false, null: false
    t.date "expiry_date"
    t.integer "percent_off", default: 0, null: false
    t.index ["organisation_id"], name: "index_subscriptions_on_organisation_id"
    t.index ["stripe_user_id"], name: "index_subscriptions_on_stripe_user_id", unique: true
  end

  create_table "themes", force: :cascade do |t|
    t.string "name", null: false
    t.integer "parent_id"
    t.index ["name"], name: "index_themes_on_name", unique: true
    t.index ["parent_id"], name: "index_themes_on_parent_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.integer "organisation_id"
    t.string "first_name", limit: 255
    t.string "last_name", limit: 255
    t.string "job_role", limit: 255
    t.string "email", limit: 255
    t.string "password_digest", limit: 255
    t.string "auth_token", limit: 255
    t.string "password_reset_token", limit: 255
    t.string "role", limit: 255, default: "User"
    t.datetime "password_reset_sent_at"
    t.datetime "last_seen"
    t.integer "sign_in_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "agree_to_terms"
    t.boolean "authorised", default: true
    t.string "unlock_token"
    t.index ["organisation_id"], name: "index_users_on_organisation_id"
  end

  add_foreign_key "enquiries", "funds"
  add_foreign_key "enquiries", "proposals"
end

# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160921134820) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace",     limit: 255
    t.text     "body"
    t.string   "resource_id",   limit: 255, null: false
    t.string   "resource_type", limit: 255, null: false
    t.integer  "author_id"
    t.string   "author_type",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "age_groups", force: :cascade do |t|
    t.string   "label"
    t.integer  "age_from"
    t.integer  "age_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "age_groups_funder_attributes", force: :cascade do |t|
    t.integer "age_group_id"
    t.integer "funder_attribute_id"
  end

  add_index "age_groups_funder_attributes", ["age_group_id", "funder_attribute_id"], name: "index_age_groups_funder_attributes", using: :btree

  create_table "age_groups_profiles", force: :cascade do |t|
    t.integer "age_group_id"
    t.integer "profile_id"
  end

  add_index "age_groups_profiles", ["age_group_id", "profile_id"], name: "index_age_groups_profiles_on_age_group_id_and_profile_id", using: :btree

  create_table "age_groups_proposals", force: :cascade do |t|
    t.integer "age_group_id"
    t.integer "proposal_id"
  end

  add_index "age_groups_proposals", ["age_group_id", "proposal_id"], name: "index_age_groups_proposals_on_age_group_id_and_proposal_id", using: :btree

  create_table "approval_months", force: :cascade do |t|
    t.string "month"
  end

  create_table "approval_months_funder_attributes", force: :cascade do |t|
    t.integer "funder_attribute_id"
    t.integer "approval_month_id"
  end

  add_index "approval_months_funder_attributes", ["approval_month_id", "funder_attribute_id"], name: "index_approval_months_funder_attributes", using: :btree
  add_index "approval_months_funder_attributes", ["approval_month_id"], name: "index_approval_months_funder_attributes_on_approval_month_id", using: :btree
  add_index "approval_months_funder_attributes", ["funder_attribute_id"], name: "index_approval_months_funder_attributes_on_funder_attribute_id", using: :btree

  create_table "beneficiaries", force: :cascade do |t|
    t.string   "label",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "category"
    t.string   "sort"
  end

  create_table "beneficiaries_funder_attributes", force: :cascade do |t|
    t.integer  "funder_attribute_id"
    t.integer  "beneficiary_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "beneficiaries_funder_attributes", ["beneficiary_id", "funder_attribute_id"], name: "index_beneficiaries_funder_attributes", using: :btree
  add_index "beneficiaries_funder_attributes", ["beneficiary_id"], name: "index_beneficiaries_funder_attributes_on_beneficiary_id", using: :btree

  create_table "beneficiaries_profiles", force: :cascade do |t|
    t.integer "beneficiary_id"
    t.integer "profile_id"
  end

  add_index "beneficiaries_profiles", ["beneficiary_id", "profile_id"], name: "index_beneficiaries_profiles_on_beneficiary_id_and_profile_id", using: :btree
  add_index "beneficiaries_profiles", ["beneficiary_id"], name: "index_beneficiaries_profiles_on_beneficiary_id", using: :btree
  add_index "beneficiaries_profiles", ["profile_id"], name: "index_beneficiaries_profiles_on_profile_id", using: :btree

  create_table "beneficiaries_proposals", force: :cascade do |t|
    t.integer "beneficiary_id"
    t.integer "proposal_id"
  end

  add_index "beneficiaries_proposals", ["beneficiary_id"], name: "index_beneficiaries_proposals_on_beneficiary_id", using: :btree
  add_index "beneficiaries_proposals", ["proposal_id"], name: "index_beneficiaries_proposals_on_proposal_id", using: :btree

  create_table "countries", force: :cascade do |t|
    t.string  "name",     limit: 255
    t.string  "alpha2",   limit: 255
    t.integer "priority",             default: 0
  end

  add_index "countries", ["name", "alpha2"], name: "index_countries_on_name_and_alpha2", unique: true, using: :btree

  create_table "countries_funder_attributes", force: :cascade do |t|
    t.integer "funder_attribute_id"
    t.integer "country_id"
  end

  add_index "countries_funder_attributes", ["country_id", "funder_attribute_id"], name: "index_countries_funder_attributes", using: :btree
  add_index "countries_funder_attributes", ["country_id"], name: "index_countries_funder_attributes_on_country_id", using: :btree
  add_index "countries_funder_attributes", ["funder_attribute_id"], name: "index_countries_funder_attributes_on_funder_attribute_id", using: :btree

  create_table "countries_funds", force: :cascade do |t|
    t.integer  "country_id"
    t.integer  "fund_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "countries_funds", ["country_id"], name: "index_countries_funds_on_country_id", using: :btree
  add_index "countries_funds", ["fund_id"], name: "index_countries_funds_on_fund_id", using: :btree

  create_table "countries_grants", force: :cascade do |t|
    t.integer  "country_id"
    t.integer  "grant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "countries_grants", ["country_id", "grant_id"], name: "index_countries_grants_on_country_id_and_grant_id", using: :btree
  add_index "countries_grants", ["country_id"], name: "index_countries_grants_on_country_id", using: :btree
  add_index "countries_grants", ["grant_id"], name: "index_countries_grants_on_grant_id", using: :btree

  create_table "countries_profiles", force: :cascade do |t|
    t.integer "country_id"
    t.integer "profile_id"
  end

  add_index "countries_profiles", ["country_id", "profile_id"], name: "index_countries_profiles_on_country_id_and_profile_id", using: :btree
  add_index "countries_profiles", ["country_id"], name: "index_countries_profiles_on_country_id", using: :btree
  add_index "countries_profiles", ["profile_id"], name: "index_countries_profiles_on_profile_id", using: :btree

  create_table "countries_proposals", force: :cascade do |t|
    t.integer "country_id"
    t.integer "proposal_id"
  end

  add_index "countries_proposals", ["country_id"], name: "index_countries_proposals_on_country_id", using: :btree
  add_index "countries_proposals", ["proposal_id"], name: "index_countries_proposals_on_proposal_id", using: :btree

  create_table "deadlines", force: :cascade do |t|
    t.integer  "fund_id"
    t.datetime "deadline"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "deadlines", ["fund_id"], name: "index_deadlines_on_fund_id", using: :btree

  create_table "decision_makers", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "decision_makers_funds", force: :cascade do |t|
    t.integer  "decision_maker_id"
    t.integer  "fund_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "decision_makers_funds", ["decision_maker_id"], name: "index_decision_makers_funds_on_decision_maker_id", using: :btree
  add_index "decision_makers_funds", ["fund_id"], name: "index_decision_makers_funds_on_fund_id", using: :btree

  create_table "districts", force: :cascade do |t|
    t.integer "country_id"
    t.string  "label",                                                   limit: 255
    t.string  "district",                                                limit: 255
    t.string  "subdivision",                                             limit: 255
    t.text    "geometry"
    t.string  "region"
    t.string  "sub_country"
    t.string  "slug"
    t.string  "indices_year"
    t.integer "indices_rank"
    t.float   "indices_rank_proportion_most_deprived_ten_percent"
    t.integer "indices_income_rank"
    t.float   "indices_income_proportion_most_deprived_ten_percent"
    t.integer "indices_employment_rank"
    t.float   "indices_employment_proportion_most_deprived_ten_percent"
    t.integer "indices_education_rank"
    t.float   "indices_education_proportion_most_deprived_ten_percent"
    t.integer "indices_health_rank"
    t.float   "indices_health_proportion_most_deprived_ten_percent"
    t.integer "indices_crime_rank"
    t.float   "indices_crime_proportion_most_deprived_ten_percent"
    t.integer "indices_barriers_rank"
    t.float   "indices_barriers_proportion_most_deprived_ten_percent"
    t.integer "indices_living_rank"
    t.float   "indices_living_proportion_most_deprived_ten_percent"
  end

  add_index "districts", ["country_id"], name: "index_districts_on_country_id", using: :btree

  create_table "districts_funder_attributes", force: :cascade do |t|
    t.integer  "funder_attribute_id"
    t.integer  "district_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "districts_funder_attributes", ["district_id", "funder_attribute_id"], name: "index_districts_funder_attributes", using: :btree
  add_index "districts_funder_attributes", ["district_id"], name: "index_districts_funder_attributes_on_district_id", using: :btree
  add_index "districts_funder_attributes", ["funder_attribute_id"], name: "index_districts_funder_attributes_on_funder_attribute_id", using: :btree

  create_table "districts_funds", force: :cascade do |t|
    t.integer  "district_id"
    t.integer  "fund_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "districts_funds", ["district_id"], name: "index_districts_funds_on_district_id", using: :btree
  add_index "districts_funds", ["fund_id"], name: "index_districts_funds_on_fund_id", using: :btree

  create_table "districts_grants", force: :cascade do |t|
    t.integer  "district_id"
    t.integer  "grant_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "districts_grants", ["district_id", "grant_id"], name: "index_districts_grants_on_district_id_and_grant_id", using: :btree
  add_index "districts_grants", ["district_id"], name: "index_districts_grants_on_district_id", using: :btree
  add_index "districts_grants", ["grant_id"], name: "index_districts_grants_on_grant_id", using: :btree

  create_table "districts_profiles", force: :cascade do |t|
    t.integer "district_id"
    t.integer "profile_id"
  end

  add_index "districts_profiles", ["district_id", "profile_id"], name: "index_districts_profiles_on_district_id_and_profile_id", using: :btree
  add_index "districts_profiles", ["district_id"], name: "index_districts_profiles_on_district_id", using: :btree
  add_index "districts_profiles", ["profile_id"], name: "index_districts_profiles_on_profile_id", using: :btree

  create_table "districts_proposals", force: :cascade do |t|
    t.integer "district_id"
    t.integer "proposal_id"
  end

  add_index "districts_proposals", ["district_id"], name: "index_districts_proposals_on_district_id", using: :btree
  add_index "districts_proposals", ["proposal_id"], name: "index_districts_proposals_on_proposal_id", using: :btree

  create_table "documents", force: :cascade do |t|
    t.string   "name"
    t.string   "link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "documents_funds", force: :cascade do |t|
    t.integer  "document_id"
    t.integer  "fund_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "documents_funds", ["document_id"], name: "index_documents_funds_on_document_id", using: :btree
  add_index "documents_funds", ["fund_id"], name: "index_documents_funds_on_fund_id", using: :btree

  create_table "eligibilities", force: :cascade do |t|
    t.integer  "recipient_id"
    t.integer  "restriction_id"
    t.boolean  "eligible"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "eligibilities", ["recipient_id"], name: "index_eligibilities_on_recipient_id", using: :btree
  add_index "eligibilities", ["restriction_id"], name: "index_eligibilities_on_restriction_id", using: :btree

  create_table "enquiries", force: :cascade do |t|
    t.integer  "recipient_id"
    t.integer  "funder_id"
    t.boolean  "new_project"
    t.boolean  "new_location"
    t.integer  "amount_seeking"
    t.integer  "duration_seeking"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "approach_funder_count", default: 0
    t.string   "funding_stream"
    t.integer  "fund_id"
    t.integer  "proposal_id"
  end

  add_index "enquiries", ["fund_id"], name: "index_enquiries_on_fund_id", using: :btree
  add_index "enquiries", ["funder_id"], name: "index_enquiries_on_funder_id", using: :btree
  add_index "enquiries", ["proposal_id"], name: "index_enquiries_on_proposal_id", using: :btree
  add_index "enquiries", ["recipient_id"], name: "index_enquiries_on_recipient_id", using: :btree

  create_table "features", force: :cascade do |t|
    t.integer  "funder_id"
    t.integer  "recipient_id"
    t.boolean  "data_requested"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "request_amount_awarded"
    t.boolean  "request_funding_dates"
    t.boolean  "request_funding_countries"
    t.boolean  "request_grant_count"
    t.boolean  "request_applications_count"
    t.boolean  "request_enquiry_count"
    t.boolean  "request_funding_types"
    t.boolean  "request_funding_streams"
    t.boolean  "request_approval_months"
  end

  add_index "features", ["funder_id"], name: "index_features_on_funder_id", using: :btree
  add_index "features", ["recipient_id"], name: "index_features_on_recipient_id", using: :btree

  create_table "feedbacks", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "nps"
    t.integer  "taken_away"
    t.integer  "informs_decision"
    t.text     "other"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "application_frequency"
    t.string   "grant_frequency"
    t.string   "marketing_frequency"
    t.integer  "price"
    t.string   "most_useful"
    t.integer  "suitable"
  end

  add_index "feedbacks", ["user_id"], name: "index_feedbacks_on_user_id", using: :btree

  create_table "funder_attributes", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "funder_id"
    t.string   "period"
    t.integer  "grant_count"
    t.integer  "application_count"
    t.integer  "enquiry_count"
    t.decimal  "funding_size_average"
    t.decimal  "funding_size_min"
    t.decimal  "funding_size_max"
    t.decimal  "funding_duration_average"
    t.decimal  "funding_duration_min"
    t.decimal  "funding_duration_max"
    t.decimal  "funded_average_age"
    t.decimal  "funded_average_income"
    t.decimal  "funded_average_paid_staff"
    t.string   "funding_stream"
    t.integer  "year"
    t.integer  "beneficiary_min_age"
    t.integer  "beneficiary_max_age"
    t.decimal  "funded_age_temp"
    t.decimal  "funded_income_temp"
    t.string   "application_link"
    t.string   "application_details"
    t.text     "soft_restrictions"
    t.text     "approval_months_by_count"
    t.string   "approval_months_by_giving"
    t.string   "countries_by_count"
    t.string   "countries_by_giving"
    t.string   "regions_by_count"
    t.string   "regions_by_giving"
    t.string   "funding_streams_by_count"
    t.string   "funding_streams_by_giving"
    t.text     "description"
    t.text     "map_data"
    t.text     "shared_recipient_ids"
    t.integer  "no_of_recipients_funded"
  end

  add_index "funder_attributes", ["funder_id"], name: "index_funder_attributes_on_funder_id", using: :btree

  create_table "funder_attributes_funding_types", force: :cascade do |t|
    t.integer "funder_attribute_id"
    t.integer "funding_type_id"
  end

  add_index "funder_attributes_funding_types", ["funder_attribute_id", "funding_type_id"], name: "index_funder_attributes_funding_types", using: :btree
  add_index "funder_attributes_funding_types", ["funder_attribute_id"], name: "index_funder_attributes_funding_types_on_funder_attribute_id", using: :btree
  add_index "funder_attributes_funding_types", ["funding_type_id"], name: "index_funder_attributes_funding_types_on_funding_type_id", using: :btree

  create_table "funding_streams", force: :cascade do |t|
    t.string   "label"
    t.string   "group"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "funding_streams_organisations", force: :cascade do |t|
    t.integer  "funder_id"
    t.integer  "funding_stream_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "funding_streams_organisations", ["funder_id", "funding_stream_id"], name: "index_funding_streams_organisations", using: :btree
  add_index "funding_streams_organisations", ["funder_id"], name: "index_funding_streams_organisations_on_funder_id", using: :btree
  add_index "funding_streams_organisations", ["funding_stream_id"], name: "index_funding_streams_organisations_on_funding_stream_id", using: :btree

  create_table "funding_streams_restrictions", force: :cascade do |t|
    t.integer  "funding_stream_id"
    t.integer  "restriction_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "funding_streams_restrictions", ["funding_stream_id", "restriction_id"], name: "index_funding_streams_restrictions", using: :btree
  add_index "funding_streams_restrictions", ["funding_stream_id"], name: "index_funding_streams_restrictions_on_funding_stream_id", using: :btree
  add_index "funding_streams_restrictions", ["restriction_id"], name: "index_funding_streams_restrictions_on_restriction_id", using: :btree

  create_table "funding_types", force: :cascade do |t|
    t.string "label"
  end

  add_index "funding_types", ["label"], name: "index_funding_types_on_label", unique: true, using: :btree

  create_table "funding_types_funds", force: :cascade do |t|
    t.integer  "funding_type_id"
    t.integer  "fund_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "funding_types_funds", ["fund_id"], name: "index_funding_types_funds_on_fund_id", using: :btree
  add_index "funding_types_funds", ["funding_type_id"], name: "index_funding_types_funds_on_funding_type_id", using: :btree

  create_table "funds", force: :cascade do |t|
    t.integer  "funder_id"
    t.string   "type_of_fund"
    t.string   "name"
    t.text     "description"
    t.string   "slug"
    t.boolean  "open_call"
    t.boolean  "active"
    t.string   "key_criteria"
    t.string   "currency"
    t.boolean  "amount_known"
    t.boolean  "amount_min_limited"
    t.boolean  "amount_max_limited"
    t.integer  "amount_min"
    t.integer  "amount_max"
    t.text     "amount_notes"
    t.boolean  "duration_months_known"
    t.boolean  "duration_months_min_limited"
    t.boolean  "duration_months_max_limited"
    t.integer  "duration_months_min"
    t.integer  "duration_months_max"
    t.text     "duration_months_notes"
    t.boolean  "deadlines_known"
    t.boolean  "deadlines_limited"
    t.integer  "decision_in_months"
    t.boolean  "stages_known"
    t.integer  "stages_count"
    t.text     "match_funding_restrictions"
    t.text     "payment_procedure"
    t.boolean  "accepts_calls_known"
    t.boolean  "accepts_calls"
    t.string   "contact_number"
    t.string   "contact_email"
    t.integer  "geographic_scale"
    t.boolean  "geographic_scale_limited"
    t.boolean  "restrictions_known"
    t.boolean  "outcomes_known"
    t.boolean  "documents_known"
    t.boolean  "decision_makers_known"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.boolean  "open_data",                       default: false
    t.date     "period_start"
    t.date     "period_end"
    t.integer  "grant_count"
    t.integer  "recipient_count"
    t.float    "amount_mean_historic"
    t.float    "amount_median_historic"
    t.float    "amount_min_historic"
    t.float    "amount_max_historic"
    t.float    "duration_months_mean_historic"
    t.float    "duration_months_median_historic"
    t.float    "duration_months_min_historic"
    t.float    "duration_months_max_historic"
    t.jsonb    "org_type_distribution"
    t.jsonb    "operating_for_distribution"
    t.jsonb    "income_distribution"
    t.jsonb    "employees_distribution"
    t.jsonb    "volunteers_distribution"
    t.jsonb    "geographic_scale_distribution"
    t.integer  "beneficiary_min_age_historic"
    t.integer  "beneficiary_max_age_historic"
    t.jsonb    "gender_distribution"
    t.jsonb    "amount_awarded_distribution"
    t.jsonb    "award_month_distribution"
    t.jsonb    "country_distribution"
    t.string   "application_link"
  end

  add_index "funds", ["funder_id"], name: "index_funds_on_funder_id", using: :btree
  add_index "funds", ["slug"], name: "index_funds_on_slug", using: :btree

  create_table "funds_outcomes", force: :cascade do |t|
    t.integer  "fund_id"
    t.integer  "outcome_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "funds_outcomes", ["fund_id"], name: "index_funds_outcomes_on_fund_id", using: :btree
  add_index "funds_outcomes", ["outcome_id"], name: "index_funds_outcomes_on_outcome_id", using: :btree

  create_table "funds_restrictions", force: :cascade do |t|
    t.integer  "fund_id"
    t.integer  "restriction_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "funds_restrictions", ["fund_id"], name: "index_funds_restrictions_on_fund_id", using: :btree
  add_index "funds_restrictions", ["restriction_id"], name: "index_funds_restrictions_on_restriction_id", using: :btree

  create_table "grants", force: :cascade do |t|
    t.integer  "funder_id"
    t.integer  "recipient_id"
    t.string   "funding_stream",                 limit: 255
    t.string   "grant_type",                     limit: 255
    t.string   "attention_how",                  limit: 255
    t.integer  "amount_awarded"
    t.integer  "amount_applied"
    t.integer  "installments"
    t.date     "approved_on"
    t.date     "start_on"
    t.date     "end_on"
    t.date     "attention_on"
    t.date     "applied_on"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "days_from_attention_to_applied"
    t.integer  "days_from_applied_to_approved"
    t.integer  "days_form_approval_to_start"
    t.integer  "days_from_start_to_end"
    t.boolean  "open_call"
  end

  add_index "grants", ["funder_id", "recipient_id"], name: "index_grants_on_funder_id_and_recipient_id", using: :btree
  add_index "grants", ["funder_id"], name: "index_grants_on_funder_id", using: :btree
  add_index "grants", ["recipient_id"], name: "index_grants_on_recipient_id", using: :btree

  create_table "implementations", force: :cascade do |t|
    t.string   "label",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "implementations_profiles", force: :cascade do |t|
    t.integer "implementation_id"
    t.integer "profile_id"
  end

  add_index "implementations_profiles", ["implementation_id", "profile_id"], name: "index_implementations_profiles", using: :btree
  add_index "implementations_profiles", ["implementation_id"], name: "index_implementations_profiles_on_implementation_id", using: :btree
  add_index "implementations_profiles", ["profile_id"], name: "index_implementations_profiles_on_profile_id", using: :btree

  create_table "implementations_proposals", force: :cascade do |t|
    t.integer "implementation_id"
    t.integer "proposal_id"
  end

  add_index "implementations_proposals", ["implementation_id", "proposal_id"], name: "index_implementations_proposals", using: :btree

  create_table "implementors", force: :cascade do |t|
    t.string   "label",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "implementors_profiles", force: :cascade do |t|
    t.integer "implementor_id"
    t.integer "profile_id"
  end

  add_index "implementors_profiles", ["implementor_id", "profile_id"], name: "index_implementors_profiles_on_implementor_id_and_profile_id", using: :btree
  add_index "implementors_profiles", ["implementor_id"], name: "index_implementors_profiles_on_implementor_id", using: :btree
  add_index "implementors_profiles", ["profile_id"], name: "index_implementors_profiles_on_profile_id", using: :btree

  create_table "organisations", force: :cascade do |t|
    t.string   "name",                            limit: 255
    t.string   "contact_number",                  limit: 255
    t.string   "website",                         limit: 255
    t.string   "street_address",                  limit: 255
    t.string   "city",                            limit: 255
    t.string   "region",                          limit: 255
    t.string   "postal_code",                     limit: 255
    t.string   "country",                         limit: 255
    t.string   "charity_number",                  limit: 255
    t.string   "company_number",                  limit: 255
    t.string   "slug",                            limit: 255
    t.string   "type",                            limit: 255
    t.text     "mission"
    t.string   "status",                          limit: 255, default: "Active - currently operational"
    t.date     "founded_on"
    t.date     "registered_on"
    t.boolean  "registered"
    t.boolean  "active_on_beehive"
    t.datetime "created_at",                                                                             null: false
    t.datetime "updated_at",                                                                             null: false
    t.integer  "recipient_funder_accesses_count"
    t.integer  "org_type"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "contact_email"
    t.string   "charity_name"
    t.string   "charity_status"
    t.float    "charity_income"
    t.float    "charity_spending"
    t.string   "charity_recent_accounts_link"
    t.string   "charity_trustees"
    t.string   "charity_employees"
    t.string   "charity_volunteers"
    t.string   "charity_year_ending"
    t.string   "charity_days_overdue"
    t.string   "charity_registered_date"
    t.string   "company_name"
    t.string   "company_type"
    t.string   "company_status"
    t.date     "company_incorporated_date"
    t.date     "company_last_accounts_date"
    t.date     "company_next_accounts_date"
    t.date     "company_accounts_due_date"
    t.date     "company_next_annual_return_date"
    t.date     "company_last_annual_return_date"
    t.date     "company_annual_return_due_date"
    t.text     "company_sic",                                                                                         array: true
    t.string   "company_recent_accounts_link"
    t.integer  "grants_count",                                default: 0
    t.integer  "operating_for"
    t.boolean  "multi_national"
    t.integer  "income"
    t.integer  "employees"
    t.integer  "volunteers"
    t.integer  "funds_checked",                               default: 0,                                null: false
  end

  add_index "organisations", ["id", "type"], name: "index_organisations_on_id_and_type", using: :btree
  add_index "organisations", ["slug"], name: "index_organisations_on_slug", unique: true, using: :btree

  create_table "outcomes", force: :cascade do |t|
    t.string   "outcome"
    t.string   "link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "profiles", force: :cascade do |t|
    t.integer  "organisation_id"
    t.string   "gender",                         limit: 255
    t.string   "currency",                       limit: 255
    t.integer  "year"
    t.integer  "min_age"
    t.integer  "max_age"
    t.integer  "income"
    t.integer  "expenditure"
    t.integer  "volunteer_count"
    t.integer  "staff_count"
    t.integer  "job_role_count"
    t.integer  "department_count"
    t.integer  "goods_count"
    t.integer  "units_count"
    t.integer  "services_count"
    t.integer  "beneficiaries_count"
    t.boolean  "income_actual"
    t.boolean  "expenditure_actual"
    t.boolean  "beneficiaries_count_actual"
    t.boolean  "units_count_actual"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.boolean  "does_sell"
    t.integer  "trustee_count"
    t.string   "state"
    t.boolean  "beneficiaries_other_required"
    t.string   "beneficiaries_other"
    t.boolean  "implementors_other_required"
    t.string   "implementors_other"
    t.boolean  "implementations_other_required"
    t.string   "implementations_other"
    t.boolean  "affect_people"
    t.boolean  "affect_other"
  end

  add_index "profiles", ["organisation_id"], name: "index_profiles_on_organisation_id", using: :btree
  add_index "profiles", ["state"], name: "index_profiles_on_state", using: :btree

  create_table "proposals", force: :cascade do |t|
    t.integer  "recipient_id"
    t.string   "title"
    t.string   "tagline"
    t.string   "gender"
    t.string   "outcome1"
    t.string   "outcome2"
    t.string   "outcome3"
    t.string   "outcome4"
    t.string   "outcome5"
    t.string   "beneficiaries_other"
    t.integer  "min_age"
    t.integer  "max_age"
    t.integer  "beneficiaries_count"
    t.integer  "funding_duration"
    t.float    "activity_costs"
    t.float    "people_costs"
    t.float    "capital_costs"
    t.float    "other_costs"
    t.float    "total_costs"
    t.boolean  "activity_costs_estimated",       default: false
    t.boolean  "people_costs_estimated",         default: false
    t.boolean  "capital_costs_estimated",        default: false
    t.boolean  "other_costs_estimated",          default: false
    t.boolean  "all_funding_required"
    t.boolean  "beneficiaries_other_required"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.string   "type_of_support"
    t.string   "state",                          default: "initial"
    t.boolean  "affect_people"
    t.boolean  "affect_other"
    t.integer  "affect_geo"
    t.boolean  "total_costs_estimated",          default: false
    t.string   "funding_type"
    t.boolean  "private"
    t.boolean  "implementations_other_required"
    t.string   "implementations_other"
  end

  add_index "proposals", ["recipient_id"], name: "index_proposals_on_recipient_id", using: :btree
  add_index "proposals", ["state"], name: "index_proposals_on_state", using: :btree

  create_table "recipient_funder_accesses", force: :cascade do |t|
    t.integer  "recipient_id"
    t.integer  "funder_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recommendations", force: :cascade do |t|
    t.integer  "funder_id"
    t.integer  "recipient_id"
    t.float    "score",                         default: 0.0
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.string   "recommendation_quality"
    t.string   "eligibility"
    t.float    "grant_amount_recommendation",   default: 0.0
    t.float    "grant_duration_recommendation", default: 0.0
    t.float    "total_recommendation",          default: 0.0
    t.float    "org_type_score"
    t.float    "beneficiary_score"
    t.float    "location_score"
    t.integer  "proposal_id"
    t.integer  "fund_id"
    t.string   "fund_slug"
  end

  add_index "recommendations", ["funder_id"], name: "index_recommendations_on_funder_id", using: :btree
  add_index "recommendations", ["proposal_id", "fund_id"], name: "index_recommendations_on_proposal_id_and_fund_id", unique: true, using: :btree
  add_index "recommendations", ["proposal_id", "fund_slug"], name: "index_recommendations_on_proposal_id_and_fund_slug", unique: true, using: :btree
  add_index "recommendations", ["recipient_id"], name: "index_recommendations_on_recipient_id", using: :btree

  create_table "restrictions", force: :cascade do |t|
    t.string   "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean  "invert"
  end

  create_table "stages", force: :cascade do |t|
    t.integer  "fund_id"
    t.string   "name"
    t.integer  "position"
    t.boolean  "feedback_provided"
    t.string   "link"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "stages", ["fund_id"], name: "index_stages_on_fund_id", using: :btree

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "organisation_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "stripe_user_id"
    t.boolean  "active",          default: false, null: false
  end

  add_index "subscriptions", ["organisation_id"], name: "index_subscriptions_on_organisation_id", using: :btree
  add_index "subscriptions", ["stripe_user_id"], name: "index_subscriptions_on_stripe_user_id", unique: true, using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
    t.string  "slug"
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree
  add_index "tags", ["slug"], name: "index_tags_on_slug", using: :btree

  create_table "users", force: :cascade do |t|
    t.integer  "organisation_id"
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.string   "job_role",               limit: 255
    t.string   "user_email",             limit: 255
    t.string   "password_digest",        limit: 255
    t.string   "auth_token",             limit: 255
    t.string   "password_reset_token",   limit: 255
    t.string   "role",                   limit: 255, default: "User"
    t.datetime "password_reset_sent_at"
    t.datetime "last_seen"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.boolean  "agree_to_terms"
    t.boolean  "authorised",                         default: true
    t.string   "unlock_token"
  end

  add_index "users", ["organisation_id"], name: "index_users_on_organisation_id", using: :btree

  add_foreign_key "deadlines", "funds"
  add_foreign_key "enquiries", "funds"
  add_foreign_key "enquiries", "proposals"
  add_foreign_key "stages", "funds"
end

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

ActiveRecord::Schema.define(version: 20151120150613) do

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

  create_table "countries", force: :cascade do |t|
    t.string  "name",     limit: 255
    t.string  "alpha2",   limit: 255
    t.integer "priority",             default: 0
  end

  create_table "countries_enquiries", force: :cascade do |t|
    t.integer "enquiry_id"
    t.integer "country_id"
  end

  add_index "countries_enquiries", ["country_id", "enquiry_id"], name: "index_countries_enquiries_on_country_id_and_enquiry_id", using: :btree
  add_index "countries_enquiries", ["enquiry_id"], name: "index_countries_enquiries_on_enquiry_id", using: :btree

  create_table "countries_funder_attributes", force: :cascade do |t|
    t.integer "funder_attribute_id"
    t.integer "country_id"
  end

  add_index "countries_funder_attributes", ["country_id", "funder_attribute_id"], name: "index_countries_funder_attributes", using: :btree
  add_index "countries_funder_attributes", ["country_id"], name: "index_countries_funder_attributes_on_country_id", using: :btree
  add_index "countries_funder_attributes", ["funder_attribute_id"], name: "index_countries_funder_attributes_on_funder_attribute_id", using: :btree

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

  create_table "districts", force: :cascade do |t|
    t.integer "country_id"
    t.string  "label",       limit: 255
    t.string  "district",    limit: 255
    t.string  "subdivision", limit: 255
  end

  add_index "districts", ["country_id"], name: "index_districts_on_country_id", using: :btree

  create_table "districts_enquiries", force: :cascade do |t|
    t.integer "enquiry_id"
    t.integer "district_id"
  end

  add_index "districts_enquiries", ["district_id", "enquiry_id"], name: "index_districts_enquiries_on_district_id_and_enquiry_id", using: :btree
  add_index "districts_enquiries", ["enquiry_id"], name: "index_districts_enquiries_on_enquiry_id", using: :btree

  create_table "districts_funder_attributes", force: :cascade do |t|
    t.integer  "funder_attribute_id"
    t.integer  "district_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "districts_funder_attributes", ["district_id", "funder_attribute_id"], name: "index_districts_funder_attributes", using: :btree
  add_index "districts_funder_attributes", ["district_id"], name: "index_districts_funder_attributes_on_district_id", using: :btree
  add_index "districts_funder_attributes", ["funder_attribute_id"], name: "index_districts_funder_attributes_on_funder_attribute_id", using: :btree

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
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "approach_funder_count"
    t.string   "funding_stream"
  end

  add_index "enquiries", ["funder_id"], name: "index_enquiries_on_funder_id", using: :btree
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
    t.string   "status",                          limit: 255
    t.date     "founded_on"
    t.date     "registered_on"
    t.boolean  "registered"
    t.boolean  "active_on_beehive"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "recipient_funder_accesses_count"
  end

  add_index "organisations", ["id", "type"], name: "index_organisations_on_id_and_type", using: :btree
  add_index "organisations", ["slug"], name: "index_organisations_on_slug", unique: true, using: :btree

  create_table "plans", force: :cascade do |t|
    t.string   "name"
    t.float    "price"
    t.string   "interval"
    t.text     "features"
    t.boolean  "highlight"
    t.integer  "display_order"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "profiles", force: :cascade do |t|
    t.integer  "organisation_id"
    t.string   "gender",                     limit: 255
    t.string   "currency",                   limit: 255
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
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "does_sell"
    t.integer  "trustee_count"
    t.string   "state"
  end

  add_index "profiles", ["organisation_id"], name: "index_profiles_on_organisation_id", using: :btree
  add_index "profiles", ["state"], name: "index_profiles_on_state", using: :btree

  create_table "recipient_attributes", force: :cascade do |t|
    t.integer  "recipient_id"
    t.text     "problem"
    t.text     "solution"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "recipient_attributes", ["recipient_id"], name: "index_recipient_attributes_on_recipient_id", using: :btree

  create_table "recipient_funder_accesses", force: :cascade do |t|
    t.integer  "recipient_id"
    t.integer  "funder_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recommendations", force: :cascade do |t|
    t.integer  "funder_id"
    t.integer  "recipient_id"
    t.float    "score",                  default: 0.0
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "recommendation_quality"
    t.string   "eligibility"
  end

  add_index "recommendations", ["funder_id"], name: "index_recommendations_on_funder_id", using: :btree
  add_index "recommendations", ["recipient_id"], name: "index_recommendations_on_recipient_id", using: :btree

  create_table "restrictions", force: :cascade do |t|
    t.string   "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean  "invert"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "plan_id"
    t.integer  "organisation_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "subscriptions", ["organisation_id"], name: "index_subscriptions_on_organisation_id", using: :btree
  add_index "subscriptions", ["plan_id"], name: "index_subscriptions_on_plan_id", using: :btree

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
  end

  add_index "users", ["organisation_id"], name: "index_users_on_organisation_id", using: :btree

end

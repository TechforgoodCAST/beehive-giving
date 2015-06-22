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

ActiveRecord::Schema.define(version: 20150622114712) do

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

  create_table "beneficiaries", force: :cascade do |t|
    t.string   "label",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "beneficiaries_funder_attributes", force: :cascade do |t|
    t.integer  "funder_attribute_id"
    t.integer  "beneficiary_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "beneficiaries_profiles", force: :cascade do |t|
    t.integer "beneficiary_id"
    t.integer "profile_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name",   limit: 255
    t.string "alpha2", limit: 255
  end

  create_table "countries_enquiries", force: :cascade do |t|
    t.integer "enquiry_id"
    t.integer "country_id"
  end

  create_table "countries_funder_attributes", force: :cascade do |t|
    t.integer "funder_attribute_id"
    t.integer "country_id"
  end

  create_table "countries_grants", force: :cascade do |t|
    t.integer  "country_id"
    t.integer  "grant_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "countries_profiles", force: :cascade do |t|
    t.integer "country_id"
    t.integer "profile_id"
  end

  create_table "districts", force: :cascade do |t|
    t.integer "country_id"
    t.string  "label",       limit: 255
    t.string  "district",    limit: 255
    t.string  "subdivision", limit: 255
  end

  create_table "districts_enquiries", force: :cascade do |t|
    t.integer "enquiry_id"
    t.integer "district_id"
  end

  create_table "districts_funder_attributes", force: :cascade do |t|
    t.integer  "funder_attribute_id"
    t.integer  "district_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "districts_grants", force: :cascade do |t|
    t.integer  "district_id"
    t.integer  "grant_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "districts_profiles", force: :cascade do |t|
    t.integer "district_id"
    t.integer "profile_id"
  end

  create_table "eligibilities", force: :cascade do |t|
    t.integer  "recipient_id"
    t.integer  "restriction_id"
    t.boolean  "eligible"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

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

  create_table "feedbacks", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "nps"
    t.integer  "taken_away"
    t.integer  "informs_decision"
    t.string   "other",            limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

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
  end

  create_table "funder_attributes_funding_types", force: :cascade do |t|
    t.integer "funder_attribute_id"
    t.integer "funding_type_id"
  end

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

  create_table "funding_streams_restrictions", force: :cascade do |t|
    t.integer  "funding_stream_id"
    t.integer  "restriction_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

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

  create_table "implementations", force: :cascade do |t|
    t.string   "label",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "implementations_profiles", force: :cascade do |t|
    t.integer "implementation_id"
    t.integer "profile_id"
  end

  create_table "implementors", force: :cascade do |t|
    t.string   "label",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "implementors_profiles", force: :cascade do |t|
    t.integer "implementor_id"
    t.integer "profile_id"
  end

  create_table "organisations", force: :cascade do |t|
    t.string   "name",              limit: 255
    t.string   "contact_number",    limit: 255
    t.string   "website",           limit: 255
    t.string   "street_address",    limit: 255
    t.string   "city",              limit: 255
    t.string   "region",            limit: 255
    t.string   "postal_code",       limit: 255
    t.string   "country",           limit: 255
    t.string   "charity_number",    limit: 255
    t.string   "company_number",    limit: 255
    t.string   "slug",              limit: 255
    t.string   "type",              limit: 255
    t.text     "mission"
    t.string   "status",            limit: 255
    t.date     "founded_on"
    t.date     "registered_on"
    t.boolean  "registered"
    t.boolean  "active_on_beehive"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "organisations", ["slug"], name: "index_organisations_on_slug", unique: true, using: :btree

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
  end

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
  end

  create_table "restrictions", force: :cascade do |t|
    t.string   "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean  "invert"
  end

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

end

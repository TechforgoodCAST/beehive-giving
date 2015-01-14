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

ActiveRecord::Schema.define(version: 20150113165324) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "beneficiaries", force: true do |t|
    t.string   "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "beneficiaries_profiles", force: true do |t|
    t.integer "beneficiary_id"
    t.integer "profile_id"
  end

  create_table "grants", force: true do |t|
    t.integer  "organisation_id"
    t.string   "funding_stream"
    t.string   "grant_type"
    t.string   "attention_how"
    t.integer  "amount_awarded"
    t.integer  "amount_applied"
    t.integer  "installments"
    t.date     "approved_on"
    t.date     "start_on"
    t.date     "end_on"
    t.date     "attention_on"
    t.date     "applied_on"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "organisations", force: true do |t|
    t.string   "name"
    t.string   "contact_number"
    t.string   "website"
    t.string   "street_address"
    t.string   "city"
    t.string   "region"
    t.string   "postal_code"
    t.string   "charity_number"
    t.string   "company_number"
    t.string   "slug"
    t.string   "organisation_type"
    t.date     "founded_on"
    t.date     "registered_on"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "organisations", ["slug"], name: "index_organisations_on_slug", unique: true, using: :btree

  create_table "profiles", force: true do |t|
    t.integer  "organisation_id"
    t.string   "gender"
    t.string   "currency"
    t.string   "goods_services"
    t.string   "who_pays"
    t.string   "who_buys"
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
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "users", force: true do |t|
    t.integer  "organisation_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "job_role"
    t.string   "user_email"
    t.string   "password_digest"
    t.string   "auth_token"
    t.string   "password_reset_token"
    t.string   "role",                   default: "User"
    t.datetime "password_reset_sent_at"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

end

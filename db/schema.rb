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

ActiveRecord::Schema.define(version: 20181204124914) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "answers", id: :serial, force: :cascade do |t|
    t.integer "category_id", null: false
    t.integer "criterion_id", null: false
    t.boolean "eligible", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category_type", default: "Proposal", null: false
    t.index ["category_id"], name: "index_answers_on_category_id"
    t.index ["category_type"], name: "index_answers_on_category_type"
    t.index ["criterion_id"], name: "index_answers_on_criterion_id"
  end

  create_table "articles", id: :serial, force: :cascade do |t|
    t.string "title", null: false
    t.string "slug", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_articles_on_slug", unique: true
  end

  create_table "assessments", force: :cascade do |t|
    t.bigint "fund_id"
    t.bigint "proposal_id"
    t.bigint "recipient_id"
    t.integer "eligibility_amount"
    t.integer "eligibility_proposal_categories"
    t.integer "eligibility_location"
    t.integer "eligibility_org_income"
    t.integer "eligibility_recipient_categories"
    t.integer "eligibility_quiz"
    t.integer "eligibility_quiz_failing"
    t.integer "eligibility_status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "revealed"
    t.jsonb "reasons", default: {}, null: false
    t.integer "suitability_quiz"
    t.integer "suitability_quiz_failing"
    t.string "suitability_status"
    t.integer "agree_count", default: 0, null: false
    t.integer "disagree_count", default: 0, null: false
    t.index ["fund_id"], name: "index_assessments_on_fund_id"
    t.index ["proposal_id"], name: "index_assessments_on_proposal_id"
    t.index ["recipient_id"], name: "index_assessments_on_recipient_id"
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

  create_table "countries_geo_areas", id: false, force: :cascade do |t|
    t.bigint "country_id", null: false
    t.bigint "geo_area_id", null: false
    t.index ["country_id", "geo_area_id"], name: "index_countries_geo_areas_on_country_id_and_geo_area_id"
    t.index ["geo_area_id", "country_id"], name: "index_countries_geo_areas_on_geo_area_id_and_country_id"
  end

  create_table "countries_proposals", id: :serial, force: :cascade do |t|
    t.integer "country_id"
    t.integer "proposal_id"
    t.index ["country_id"], name: "index_countries_proposals_on_country_id"
    t.index ["proposal_id"], name: "index_countries_proposals_on_proposal_id"
  end

  create_table "criteria", id: :serial, force: :cascade do |t|
    t.string "details", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "invert", default: false, null: false
    t.string "category", default: "Proposal", null: false
    t.string "type", default: "Restriction"
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

  create_table "districts_geo_areas", id: false, force: :cascade do |t|
    t.bigint "district_id", null: false
    t.bigint "geo_area_id", null: false
    t.index ["district_id", "geo_area_id"], name: "index_districts_geo_areas_on_district_id_and_geo_area_id"
    t.index ["geo_area_id", "district_id"], name: "index_districts_geo_areas_on_geo_area_id_and_district_id"
  end

  create_table "districts_proposals", id: :serial, force: :cascade do |t|
    t.integer "district_id"
    t.integer "proposal_id"
    t.index ["district_id"], name: "index_districts_proposals_on_district_id"
    t.index ["proposal_id"], name: "index_districts_proposals_on_proposal_id"
  end

  create_table "fund_themes", force: :cascade do |t|
    t.bigint "fund_id"
    t.bigint "theme_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fund_id"], name: "index_fund_themes_on_fund_id"
    t.index ["theme_id"], name: "index_fund_themes_on_theme_id"
  end

  create_table "funders", force: :cascade do |t|
    t.string "slug", null: false
    t.string "name", null: false
    t.string "website"
    t.string "charity_number"
    t.string "company_number"
    t.boolean "active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "primary_color"
    t.string "secondary_color"
    t.datetime "opportunities_last_updated_at", default: "2018-10-31 00:00:00", null: false
    t.integer "active_opportunities_count", default: 0, null: false
    t.index ["slug"], name: "index_funders_on_slug", unique: true
  end

  create_table "funds", id: :serial, force: :cascade do |t|
    t.integer "funder_id"
    t.string "name"
    t.text "description"
    t.string "slug"
    t.string "website"
    t.boolean "proposal_area_limited"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "links", default: {}, null: false
    t.boolean "national", default: false, null: false
    t.integer "proposal_min_amount"
    t.integer "proposal_max_amount"
    t.integer "proposal_min_duration"
    t.integer "proposal_max_duration"
    t.jsonb "proposal_categories", default: [], null: false
    t.jsonb "recipient_categories", default: [], null: false
    t.integer "recipient_min_income"
    t.integer "recipient_max_income"
    t.integer "geo_area_id"
    t.string "state", default: "draft", null: false
    t.jsonb "proposal_permitted_geographic_scales", default: [], null: false
    t.boolean "proposal_all_in_area"
    t.index ["funder_id"], name: "index_funds_on_funder_id"
    t.index ["geo_area_id"], name: "index_funds_on_geo_area_id"
    t.index ["slug"], name: "index_funds_on_slug"
  end

  create_table "geo_areas", force: :cascade do |t|
    t.string "name"
    t.string "short_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "proposal_themes", force: :cascade do |t|
    t.bigint "proposal_id"
    t.bigint "theme_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["proposal_id"], name: "index_proposal_themes_on_proposal_id"
    t.index ["theme_id"], name: "index_proposal_themes_on_theme_id"
  end

  create_table "proposals", id: :serial, force: :cascade do |t|
    t.integer "recipient_id"
    t.string "title"
    t.string "description"
    t.integer "min_duration"
    t.integer "min_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "state", default: "complete"
    t.boolean "prevent_funder_verification"
    t.integer "category_code"
    t.boolean "public_consent"
    t.string "support_details"
    t.integer "max_amount"
    t.integer "max_duration"
    t.string "geographic_scale"
    t.bigint "user_id"
    t.string "access_token"
    t.datetime "private"
    t.bigint "collection_id"
    t.string "collection_type"
    t.bigint "duplicate_of"
    t.datetime "migrated_on"
    t.integer "assessments_count", default: 0, null: false
    t.index ["collection_id"], name: "index_proposals_on_collection_id"
    t.index ["collection_type"], name: "index_proposals_on_collection_type"
    t.index ["recipient_id"], name: "index_proposals_on_recipient_id"
    t.index ["state"], name: "index_proposals_on_state"
    t.index ["user_id"], name: "index_proposals_on_user_id"
  end

  create_table "questions", id: :serial, force: :cascade do |t|
    t.integer "fund_id"
    t.integer "criterion_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "criterion_type", default: "Restriction"
    t.index ["criterion_id"], name: "index_questions_on_criterion_id"
    t.index ["fund_id"], name: "index_questions_on_fund_id"
  end

  create_table "recipients", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "website", limit: 255
    t.string "charity_number", limit: 255
    t.string "company_number", limit: 255
    t.string "slug", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "operating_for"
    t.integer "income_band"
    t.jsonb "reveals", default: [], null: false
    t.integer "category_code"
    t.string "description"
    t.bigint "user_id"
    t.bigint "district_id"
    t.bigint "country_id"
    t.bigint "duplicate_of"
    t.datetime "migrated_on"
    t.index ["country_id"], name: "index_recipients_on_country_id"
    t.index ["district_id"], name: "index_recipients_on_district_id"
    t.index ["slug"], name: "index_recipients_on_slug", unique: true
    t.index ["user_id"], name: "index_recipients_on_user_id"
  end

  create_table "themes", force: :cascade do |t|
    t.string "name", null: false
    t.integer "parent_id"
    t.jsonb "related", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.string "classes"
    t.datetime "opportunities_last_updated_at", default: "2018-10-31 00:00:00", null: false
    t.integer "active_opportunities_count", default: 0, null: false
    t.index ["name"], name: "index_themes_on_name", unique: true
    t.index ["parent_id"], name: "index_themes_on_parent_id"
    t.index ["slug"], name: "index_themes_on_slug", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.integer "organisation_id"
    t.string "first_name", limit: 255
    t.string "last_name", limit: 255
    t.string "email", limit: 255
    t.string "password_digest", limit: 255
    t.string "auth_token", limit: 255
    t.string "password_reset_token", limit: 255
    t.string "organisation_type", limit: 255, default: "Recipient"
    t.datetime "password_reset_sent_at"
    t.datetime "last_seen"
    t.integer "sign_in_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "agree_to_terms"
    t.boolean "authorised", default: true
    t.string "unlock_token"
    t.date "terms_version"
    t.boolean "marketing_consent"
    t.datetime "terms_agreed"
    t.string "stripe_user_id"
    t.datetime "update_version"
    t.index ["organisation_id"], name: "index_users_on_organisation_id"
    t.index ["organisation_type"], name: "index_users_on_organisation_type"
  end

  create_table "votes", force: :cascade do |t|
    t.bigint "assessment_id"
    t.string "relationship_to_assessment"
    t.string "relationship_details"
    t.boolean "agree_with_rating"
    t.text "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assessment_id"], name: "index_votes_on_assessment_id"
  end

  add_foreign_key "assessments", "funds"
  add_foreign_key "assessments", "proposals"
  add_foreign_key "assessments", "recipients"
  add_foreign_key "fund_themes", "funds"
  add_foreign_key "fund_themes", "themes"
  add_foreign_key "funds", "geo_areas"
  add_foreign_key "proposal_themes", "proposals"
  add_foreign_key "proposal_themes", "themes"
  add_foreign_key "proposals", "users"
  add_foreign_key "votes", "assessments"
end

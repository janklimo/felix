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

ActiveRecord::Schema.define(version: 20170113090744) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "citext"

  create_table "admins", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "superadmin",             default: false, null: false
  end

  add_index "admins", ["confirmation_token"], name: "index_admins_on_confirmation_token", unique: true, using: :btree
  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "companies", force: :cascade do |t|
    t.string   "name"
    t.integer  "admin_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "size",       default: 0, null: false
  end

  add_index "companies", ["admin_id"], name: "index_companies_on_admin_id", using: :btree

  create_table "feedback_requests", force: :cascade do |t|
    t.integer  "company_id"
    t.integer  "question_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "feedback_requests", ["company_id"], name: "index_feedback_requests_on_company_id", using: :btree
  add_index "feedback_requests", ["question_id"], name: "index_feedback_requests_on_question_id", using: :btree

  create_table "feedbacks", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "feedback_request_id"
    t.integer  "value",               default: 0, null: false
    t.text     "text"
    t.integer  "tag",                 default: 0, null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "feedbacks", ["feedback_request_id"], name: "index_feedbacks_on_feedback_request_id", using: :btree
  add_index "feedbacks", ["user_id"], name: "index_feedbacks_on_user_id", using: :btree

  create_table "metrics", force: :cascade do |t|
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "image_url"
    t.jsonb    "name",       default: {}
  end

  add_index "metrics", ["name"], name: "index_metrics_on_name", using: :gin

  create_table "options", force: :cascade do |t|
    t.integer  "value",       default: 0,  null: false
    t.integer  "question_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.jsonb    "title",       default: {}
  end

  add_index "options", ["question_id"], name: "index_options_on_question_id", using: :btree
  add_index "options", ["title"], name: "index_options_on_title", using: :gin

  create_table "questions", force: :cascade do |t|
    t.integer  "row_order"
    t.integer  "metric_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.jsonb    "title",      default: {}
    t.integer  "timing",     default: 0,  null: false
  end

  add_index "questions", ["metric_id"], name: "index_questions_on_metric_id", using: :btree
  add_index "questions", ["title"], name: "index_questions_on_title", using: :gin

  create_table "tokens", force: :cascade do |t|
    t.string   "name",       null: false
    t.integer  "user_id"
    t.integer  "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "tokens", ["company_id"], name: "index_tokens_on_company_id", using: :btree
  add_index "tokens", ["name"], name: "index_tokens_on_name", unique: true, using: :btree
  add_index "tokens", ["user_id"], name: "index_tokens_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "external_id"
    t.integer  "status",      default: 0,    null: false
    t.integer  "company_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "language",    default: "en", null: false
  end

  add_index "users", ["company_id"], name: "index_users_on_company_id", using: :btree
  add_index "users", ["external_id"], name: "index_users_on_external_id", using: :btree

  add_foreign_key "companies", "admins"
  add_foreign_key "feedback_requests", "companies"
  add_foreign_key "feedback_requests", "questions"
  add_foreign_key "feedbacks", "feedback_requests"
  add_foreign_key "feedbacks", "users"
  add_foreign_key "options", "questions"
  add_foreign_key "questions", "metrics"
  add_foreign_key "tokens", "companies"
  add_foreign_key "tokens", "users"
  add_foreign_key "users", "companies"
end

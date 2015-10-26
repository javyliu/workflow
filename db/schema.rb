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

ActiveRecord::Schema.define(version: 20151022070140) do

  create_table "approves", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "user_name",  limit: 20
    t.integer  "state",      limit: 1,   default: 0
    t.string   "des",        limit: 255
    t.integer  "episode_id", limit: 4
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "approves", ["episode_id"], name: "index_approves_on_episode_id", using: :btree
  add_index "approves", ["user_id"], name: "index_approves_on_user_id", using: :btree

  create_table "attend_rules", force: :cascade do |t|
    t.string   "name",        limit: 30
    t.string   "description", limit: 40
    t.string   "title_ids",   limit: 255
    t.string   "time_range",  limit: 40,  default: "0"
    t.integer  "min_unit",    limit: 2,   default: 30
    t.datetime "created_at",              default: '2015-03-09 14:55:03', null: false
    t.datetime "updated_at",              default: '2015-03-09 14:55:03', null: false
  end

  create_table "checkinouts", force: :cascade do |t|
    t.string   "user_id",    limit: 20
    t.date     "rec_date"
    t.datetime "checkin"
    t.datetime "checkout"
    t.datetime "ref_time"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "checkinouts", ["user_id"], name: "index_checkinouts_on_user_id", using: :btree

  create_table "departments", primary_key: "code", force: :cascade do |t|
    t.string   "name",           limit: 100
    t.integer  "attend_rule_id", limit: 2
    t.string   "mgr_code",       limit: 20
    t.string   "admin",          limit: 20
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "departments", ["attend_rule_id"], name: "index_departments_on_attend_rule_id", using: :btree
  add_index "departments", ["mgr_code"], name: "index_departments_on_mgr_code", using: :btree

  create_table "episodes", force: :cascade do |t|
    t.string   "user_id",    limit: 20
    t.string   "title",      limit: 20
    t.string   "total_time", limit: 20
    t.integer  "holiday_id", limit: 4
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "comment",    limit: 500
    t.integer  "state",      limit: 1,   default: 0
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "ck_type",    limit: 1
    t.integer  "parent_id",  limit: 4,   default: 0
  end

  add_index "episodes", ["holiday_id", "user_id"], name: "index_episodes_on_holiday_id_and_user_id", using: :btree
  add_index "episodes", ["holiday_id"], name: "index_episodes_on_holiday_id", using: :btree
  add_index "episodes", ["parent_id"], name: "index_episodes_on_parent_id", using: :btree
  add_index "episodes", ["user_id"], name: "index_episodes_on_user_id", using: :btree

  create_table "holidays", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "journals", force: :cascade do |t|
    t.string   "user_id",     limit: 20
    t.date     "update_date"
    t.integer  "check_type",  limit: 4
    t.string   "description", limit: 255
    t.integer  "dval",        limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "journals", ["user_id"], name: "index_journals_on_user_id", using: :btree

  create_table "oa_configs", force: :cascade do |t|
    t.string "key",   limit: 40
    t.string "des",   limit: 40
    t.string "value", limit: 255
  end

  create_table "report_titles", force: :cascade do |t|
    t.string  "name", limit: 40
    t.string  "des",  limit: 20
    t.integer "ord",  limit: 2
  end

  create_table "role_resources", force: :cascade do |t|
    t.integer  "role_id",       limit: 4
    t.string   "resource_name", limit: 50
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "role_resources", ["resource_name"], name: "index_role_resources_on_resource_name", using: :btree
  add_index "role_resources", ["role_id"], name: "index_role_resources_on_role_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name",         limit: 20
    t.string   "display_name", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "roles_users", id: false, force: :cascade do |t|
    t.integer "user_id", limit: 4, null: false
    t.integer "role_id", limit: 4, null: false
  end

  add_index "roles_users", ["role_id", "user_id"], name: "index_roles_users_on_role_id_and_user_id", unique: true, using: :btree

  create_table "spec_days", force: :cascade do |t|
    t.date    "sdate"
    t.boolean "is_workday", limit: 1
    t.string  "comment",    limit: 40
  end

  create_table "tbldepartment", primary_key: "deptCode", force: :cascade do |t|
    t.string "deptName",   limit: 100, null: false
    t.string "attenRules", limit: 255
    t.string "mgrCode",    limit: 20
    t.string "admin",      limit: 20
  end

  create_table "tblemployee", primary_key: "userId", force: :cascade do |t|
    t.string  "name",        limit: 20,  null: false
    t.string  "email",       limit: 40
    t.string  "department",  limit: 500
    t.integer "title",       limit: 4
    t.string  "attenRules",  limit: 255
    t.date    "expireDate"
    t.string  "deptCode",    limit: 20
    t.string  "mgrCode",     limit: 20
    t.date    "onboardDate"
    t.date    "regularDate"
  end

  create_table "users", primary_key: "uid", force: :cascade do |t|
    t.string   "user_name",                 limit: 20,   null: false
    t.string   "email",                     limit: 40
    t.string   "department",                limit: 3000
    t.string   "title",                     limit: 255
    t.date     "expire_date"
    t.string   "dept_code",                 limit: 20
    t.string   "mgr_code",                  limit: 20
    t.string   "password_digest",           limit: 255
    t.integer  "role_group",                limit: 4
    t.string   "remember_token",            limit: 255
    t.date     "onboard_date"
    t.date     "regular_date"
    t.datetime "remember_token_expires_at"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "users", ["dept_code"], name: "index_users_on_dept_code", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["mgr_code"], name: "index_users_on_mgr_code", using: :btree

  create_table "year_infos", force: :cascade do |t|
    t.integer  "year",         limit: 4
    t.string   "user_id",      limit: 20
    t.integer  "year_holiday", limit: 4,  default: 0
    t.integer  "sick_leave",   limit: 4,  default: 0
    t.integer  "affair_leave", limit: 4,  default: 0
    t.integer  "switch_leave", limit: 4,  default: 0
    t.integer  "ab_point",     limit: 8,  default: 0
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "year_infos", ["user_id"], name: "index_year_infos_on_user_id", using: :btree

end

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

ActiveRecord::Schema.define(version: 20150109085701) do

  create_table "attend_rules", force: :cascade do |t|
    t.string   "name",        limit: 30
    t.string   "description", limit: 40
    t.string   "title_ids",   limit: 255
    t.string   "time_range",  limit: 40,  default: "0"
    t.integer  "min_unit",    limit: 2,   default: 30
    t.datetime "created_at",              default: '2015-01-14 15:38:29', null: false
    t.datetime "updated_at",              default: '2015-01-14 15:38:29', null: false
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
    t.datetime "created_at",                 default: '2015-01-09 10:27:40', null: false
    t.datetime "updated_at",                 default: '2015-01-09 10:27:40', null: false
  end

  create_table "episodes", force: :cascade do |t|
    t.string   "user_id",       limit: 20
    t.integer  "holiday_id",    limit: 4
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "comment",       limit: 500
    t.string   "approved_by",   limit: 20
    t.datetime "approved_time"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "holidays", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "journals", force: :cascade do |t|
    t.string   "user_id",     limit: 20
    t.date     "update_date"
    t.integer  "check_type",  limit: 4
    t.string   "description", limit: 255
    t.integer  "dval",        limit: 4
    t.datetime "created_at",              default: '2015-01-06 22:56:18', null: false
    t.datetime "updated_at",              default: '2015-01-06 22:56:18', null: false
  end

  add_index "journals", ["user_id"], name: "index_journals_on_user_id", using: :btree

  create_table "oa_configs", force: :cascade do |t|
    t.string "key",   limit: 40
    t.string "des",   limit: 40
    t.string "value", limit: 255
  end

  create_table "report_titles", force: :cascade do |t|
    t.string  "name", limit: 20
    t.string  "des",  limit: 20
    t.integer "ord",  limit: 2
  end

  create_table "spec_days", force: :cascade do |t|
    t.date    "sdate"
    t.boolean "is_workday", limit: 1
    t.string  "comment",    limit: 40
  end

  create_table "tblabsence", id: false, force: :cascade do |t|
    t.string   "userCode",     limit: 20,  null: false
    t.date     "flddate",                  null: false
    t.string   "reason",       limit: 255
    t.integer  "absenceType",  limit: 4,   null: false
    t.datetime "approvedDate"
    t.string   "approvedBy",   limit: 20
  end

  create_table "tblcheckinout", id: false, force: :cascade do |t|
    t.string   "userId",   limit: 20, null: false
    t.date     "recDate",             null: false
    t.datetime "checkin"
    t.datetime "checkout"
    t.datetime "refTime"
  end

  create_table "tblconfigs", primary_key: "key", force: :cascade do |t|
    t.text "value", limit: 65535
  end

  create_table "tbldaytype", primary_key: "flddate", force: :cascade do |t|
    t.integer "type",    limit: 4
    t.string  "comment", limit: 40
  end

  create_table "tbldepartment", primary_key: "deptCode", force: :cascade do |t|
    t.string "deptName",   limit: 100, null: false
    t.string "attenRules", limit: 255
    t.string "mgrCode",    limit: 20
    t.string "admin",      limit: 20
  end

  create_table "tblemployee", primary_key: "userId", force: :cascade do |t|
    t.string  "name",       limit: 20,  null: false
    t.string  "email",      limit: 40
    t.string  "department", limit: 500
    t.integer "title",      limit: 4
    t.string  "attenRules", limit: 255
    t.date    "expireDate"
    t.string  "deptCode",   limit: 20
    t.string  "mgrCode",    limit: 20
  end

  create_table "tblepisode", force: :cascade do |t|
    t.string   "userId",       limit: 10
    t.string   "type",         limit: 20
    t.date     "startDate"
    t.date     "endDate"
    t.text     "comments",     limit: 65535
    t.string   "approvedBy",   limit: 10
    t.datetime "approvedDate"
  end

  create_table "tbljournal", id: false, force: :cascade do |t|
    t.string  "uid",        limit: 20,  null: false
    t.date    "updateDate"
    t.integer "tp",         limit: 4,   null: false
    t.string  "cmmt",       limit: 255
    t.integer "dval",       limit: 4,   null: false
  end

  create_table "tblovertime", id: false, force: :cascade do |t|
    t.string   "userCode",     limit: 20,  null: false
    t.date     "flddate",                  null: false
    t.string   "reason",       limit: 255
    t.datetime "approvedDate"
    t.string   "approvedBy",   limit: 20
  end

  create_table "tblpendingtasks", id: false, force: :cascade do |t|
    t.string   "engine",       limit: 40,                    null: false
    t.string   "status",       limit: 255,   default: "0",   null: false
    t.boolean  "finished",     limit: 1,     default: false, null: false
    t.binary   "content",      limit: 65535
    t.string   "refId",        limit: 20,                    null: false
    t.string   "userId",       limit: 20,                    null: false
    t.datetime "deadLine"
    t.binary   "attached",     limit: 65535
    t.integer  "alarmTimes",   limit: 1,                     null: false
    t.datetime "lstAlarmTime"
  end

  create_table "tblyearinfo", id: false, force: :cascade do |t|
    t.integer "year",        limit: 4,  null: false
    t.string  "uid",         limit: 20, null: false
    t.integer "yearHolody",  limit: 4,  null: false
    t.integer "sickLeave",   limit: 4,  null: false
    t.integer "affairLeave", limit: 4,  null: false
    t.integer "switchLeave", limit: 4,  null: false
    t.integer "aPoint",      limit: 4,  null: false
  end

  create_table "users", primary_key: "uid", force: :cascade do |t|
    t.string   "user_name",                 limit: 20,                                  null: false
    t.string   "email",                     limit: 40
    t.string   "department",                limit: 255
    t.string   "title",                     limit: 255
    t.date     "expire_date"
    t.string   "dept_code",                 limit: 20
    t.string   "mgr_code",                  limit: 20
    t.string   "password_digest",           limit: 255
    t.integer  "role_group",                limit: 4
    t.string   "remember_token",            limit: 255
    t.datetime "remember_token_expires_at"
    t.datetime "created_at",                            default: '2015-01-06 14:52:34', null: false
    t.datetime "updated_at",                            default: '2015-01-06 14:52:34', null: false
  end

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
    t.datetime "created_at",              default: '2015-01-09 22:02:50', null: false
    t.datetime "updated_at",              default: '2015-01-09 22:02:50', null: false
  end

  add_index "year_infos", ["user_id"], name: "index_year_infos_on_user_id", using: :btree

end

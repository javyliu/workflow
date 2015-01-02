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

ActiveRecord::Schema.define(version: 0) do

  create_table "tblabsence", id: false, force: :cascade do |t|
    t.string   "userCode",     limit: 20,  null: false
    t.date     "flddate",                  null: false
    t.string   "reason",       limit: 255
    t.integer  "absenceType",  limit: 4,   null: false
    t.datetime "approvedDate"
    t.string   "approvedBy",   limit: 20
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

end

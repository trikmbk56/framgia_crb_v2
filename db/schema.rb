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

ActiveRecord::Schema.define(version: 20160608041902) do

  create_table "attendees", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "event_id",   limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "attendees", ["user_id", "event_id"], name: "index_attendees_on_user_id_and_event_id", unique: true, using: :btree

  create_table "calendars", force: :cascade do |t|
    t.integer  "user_id",     limit: 4
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.integer  "color_id",    limit: 4
    t.integer  "parent_id",   limit: 4
    t.integer  "status",      limit: 4,   default: 0
    t.boolean  "is_default",              default: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "calendars", ["name"], name: "index_calendars_on_name", unique: true, using: :btree
  add_index "calendars", ["parent_id"], name: "index_calendars_on_parent_id", using: :btree

  create_table "colors", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.string   "color_hex",  limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0, null: false
    t.integer  "attempts",   limit: 4,     default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "events", force: :cascade do |t|
    t.string   "title",           limit: 255,   default: "No title"
    t.text     "description",     limit: 65535
    t.string   "status",          limit: 255
    t.string   "color",           limit: 255
    t.boolean  "all_day",                       default: false
    t.integer  "repeat_type",     limit: 4
    t.integer  "repeat_every",    limit: 4
    t.integer  "user_id",         limit: 4
    t.integer  "calendar_id",     limit: 4
    t.datetime "start_date"
    t.datetime "finish_date"
    t.datetime "start_repeat"
    t.datetime "end_repeat"
    t.datetime "exception_time"
    t.integer  "exception_type",  limit: 4
    t.integer  "parent_id",       limit: 4
    t.string   "room_id",         limit: 255
    t.text     "task_content",    limit: 65535
    t.text     "message_content", limit: 65535
    t.string   "google_event_id", limit: 255
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
  end

  add_index "events", ["google_event_id"], name: "index_events_on_google_event_id", unique: true, using: :btree

  create_table "notification_events", force: :cascade do |t|
    t.integer  "event_id",        limit: 4
    t.integer  "notification_id", limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "notification_events", ["event_id"], name: "index_notification_events_on_event_id", using: :btree
  add_index "notification_events", ["notification_id"], name: "index_notification_events_on_notification_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.string   "notification_type", limit: 255
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "permissions", force: :cascade do |t|
    t.string   "permission", limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "repeat_ons", force: :cascade do |t|
    t.integer  "repeat_on",  limit: 4
    t.integer  "event_id",   limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "user_calendars", force: :cascade do |t|
    t.integer  "user_id",       limit: 4
    t.integer  "calendar_id",   limit: 4
    t.integer  "permission_id", limit: 4
    t.integer  "color_id",      limit: 4, default: 1
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "user_calendars", ["user_id", "calendar_id"], name: "index_user_calendars_on_user_id_and_calendar_id", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",                   limit: 255
    t.string   "email",                  limit: 255, default: "",    null: false
    t.string   "avatar",                 limit: 255
    t.string   "chatwork_id",            limit: 255
    t.string   "encrypted_password",     limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "google_calendar_id",     limit: 255
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.string   "token",                  limit: 255
    t.string   "uid",                    limit: 255
    t.string   "provider",               limit: 255
    t.boolean  "email_require",                      default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "notification_events", "events"
  add_foreign_key "notification_events", "notifications"
end

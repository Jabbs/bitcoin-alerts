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

ActiveRecord::Schema.define(version: 20170821183503) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "quotes", force: :cascade do |t|
    t.string   "currency_pair",                           null: false
    t.decimal  "bid",           precision: 15, scale: 2,  null: false
    t.decimal  "ask",           precision: 15, scale: 2,  null: false
    t.decimal  "price",         precision: 15, scale: 2,  null: false
    t.decimal  "size",          precision: 20, scale: 10, null: false
    t.decimal  "volume",        precision: 20, scale: 2,  null: false
    t.decimal  "trade_id",      precision: 20,            null: false
    t.datetime "traded_at",                               null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "quotes", ["currency_pair"], name: "index_quotes_on_currency_pair", using: :btree
  add_index "quotes", ["trade_id"], name: "index_quotes_on_trade_id", using: :btree
  add_index "quotes", ["traded_at"], name: "index_quotes_on_traded_at", using: :btree

  create_table "strategies", force: :cascade do |t|
    t.string   "name"
    t.integer  "percent_change"
    t.string   "percent_change_direction"
    t.datetime "last_alert_sent_at"
    t.integer  "lookback_hours"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "currency_pair"
  end

  add_index "strategies", ["currency_pair"], name: "index_strategies_on_currency_pair", using: :btree

end

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

ActiveRecord::Schema.define(version: 20170820153950) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bitcoin_quotes", force: :cascade do |t|
    t.decimal  "bid",        null: false
    t.decimal  "ask",        null: false
    t.decimal  "spot",       null: false
    t.string   "currency",   null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "bitcoin_quotes", ["ask"], name: "index_bitcoin_quotes_on_ask", using: :btree
  add_index "bitcoin_quotes", ["bid"], name: "index_bitcoin_quotes_on_bid", using: :btree
  add_index "bitcoin_quotes", ["created_at"], name: "index_bitcoin_quotes_on_created_at", using: :btree
  add_index "bitcoin_quotes", ["spot"], name: "index_bitcoin_quotes_on_spot", using: :btree

end

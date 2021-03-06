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

ActiveRecord::Schema.define(version: 20171112173341) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bittrex_market_summaries", force: :cascade do |t|
    t.string   "market_name"
    t.decimal  "high",             precision: 25, scale: 10
    t.decimal  "low",              precision: 25, scale: 10
    t.decimal  "volume",           precision: 25, scale: 10
    t.decimal  "last",             precision: 25, scale: 10
    t.decimal  "base_volume",      precision: 25, scale: 10
    t.datetime "time_stamp"
    t.decimal  "bid",              precision: 25, scale: 10
    t.decimal  "ask",              precision: 25, scale: 10
    t.integer  "open_buy_orders"
    t.integer  "open_sell_orders"
    t.decimal  "prev_day",         precision: 25, scale: 10
    t.datetime "created"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.decimal  "btc_price",        precision: 25, scale: 10
    t.decimal  "eth_price",        precision: 25, scale: 10
  end

  add_index "bittrex_market_summaries", ["created_at"], name: "index_bittrex_market_summaries_on_created_at", using: :btree
  add_index "bittrex_market_summaries", ["market_name"], name: "index_bittrex_market_summaries_on_market_name", using: :btree

  create_table "channel_notifications", force: :cascade do |t|
    t.integer  "channel_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text     "message"
  end

  add_index "channel_notifications", ["channel_id"], name: "index_channel_notifications_on_channel_id", using: :btree
  add_index "channel_notifications", ["user_id"], name: "index_channel_notifications_on_user_id", using: :btree

  create_table "channels", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "currency_id"
    t.text     "description"
    t.text     "source_url"
    t.string   "source_name"
    t.integer  "frequency_in_minutes"
    t.boolean  "active",               default: true
    t.string   "frequency_type",       default: "continuous"
  end

  add_index "channels", ["currency_id"], name: "index_channels_on_currency_id", using: :btree

  create_table "coins", force: :cascade do |t|
    t.decimal  "acquired_price", precision: 20, scale: 10
    t.string   "currency"
    t.integer  "wallet_id"
    t.integer  "order_id"
    t.decimal  "sold_price",     precision: 20, scale: 10
    t.datetime "sold_at"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "coins", ["created_at"], name: "index_coins_on_created_at", using: :btree
  add_index "coins", ["sold_at"], name: "index_coins_on_sold_at", using: :btree
  add_index "coins", ["wallet_id"], name: "index_coins_on_wallet_id", using: :btree

  create_table "currencies", force: :cascade do |t|
    t.string   "name"
    t.string   "symbol"
    t.datetime "released_at"
    t.text     "description"
    t.boolean  "active"
    t.string   "founder"
    t.string   "hash_algorithm"
    t.string   "timestamping_method"
    t.string   "color_hexidecimal"
    t.string   "website"
    t.decimal  "supply_total",        precision: 25, scale: 10
    t.decimal  "supply_circulating",  precision: 25, scale: 10
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
  end

  create_table "daily_quotes_summaries", force: :cascade do |t|
    t.text     "quote_data"
    t.integer  "starting_quote_id"
    t.integer  "ending_quote_id"
    t.datetime "starting_quote_traded_at"
    t.datetime "ending_quote_traded_at"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "lots", force: :cascade do |t|
    t.string   "receiving_account_symbol"
    t.decimal  "aquired_asset_amount",     precision: 25, scale: 10
    t.decimal  "remaining_asset_amount",   precision: 25, scale: 10
    t.decimal  "usd_cost",                 precision: 25, scale: 10
    t.datetime "transaction_time"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
  end

  create_table "orders", force: :cascade do |t|
    t.string   "client_id",       null: false
    t.string   "price"
    t.string   "size"
    t.string   "currency_pair"
    t.string   "side"
    t.string   "stp"
    t.string   "order_type"
    t.string   "time_in_force"
    t.boolean  "post_only"
    t.string   "fill_fees"
    t.string   "filled_size"
    t.string   "executed_value"
    t.string   "status"
    t.boolean  "settled"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "simulation_id"
    t.integer  "scheme_id"
    t.string   "done_at"
    t.string   "done_reason"
    t.string   "funds"
    t.string   "specified_funds"
    t.integer  "quote_id"
    t.integer  "strategy_id"
  end

  add_index "orders", ["client_id"], name: "index_orders_on_client_id", using: :btree
  add_index "orders", ["quote_id"], name: "index_orders_on_quote_id", using: :btree
  add_index "orders", ["scheme_id"], name: "index_orders_on_scheme_id", using: :btree
  add_index "orders", ["simulation_id"], name: "index_orders_on_simulation_id", using: :btree
  add_index "orders", ["strategy_id"], name: "index_orders_on_strategy_id", using: :btree

  create_table "quotes", force: :cascade do |t|
    t.string   "currency_pair",                                               null: false
    t.decimal  "bid",                  precision: 15, scale: 2,               null: false
    t.decimal  "ask",                  precision: 15, scale: 2,               null: false
    t.decimal  "price",                precision: 15, scale: 2,               null: false
    t.decimal  "size",                 precision: 20, scale: 10,              null: false
    t.decimal  "volume",               precision: 20, scale: 2,               null: false
    t.decimal  "trade_id",             precision: 20,                         null: false
    t.datetime "traded_at",                                                   null: false
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.integer  "passing_strategy_ids",                           default: [],              array: true
  end

  add_index "quotes", ["currency_pair"], name: "index_quotes_on_currency_pair", using: :btree
  add_index "quotes", ["trade_id"], name: "index_quotes_on_trade_id", using: :btree
  add_index "quotes", ["traded_at"], name: "index_quotes_on_traded_at", using: :btree

  create_table "rules", force: :cascade do |t|
    t.integer  "strategy_id"
    t.decimal  "percent_increase",              precision: 12, scale: 4
    t.decimal  "percent_decrease",              precision: 12, scale: 4
    t.integer  "lookback_minutes"
    t.string   "comparison_logic"
    t.string   "operator"
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.integer  "channel_id"
    t.decimal  "ceiling",                       precision: 25, scale: 10
    t.decimal  "floor",                         precision: 25, scale: 10
    t.datetime "time_constraint_start"
    t.datetime "time_constraint_end"
    t.string   "side"
    t.string   "currency_pair"
    t.string   "comparison_table"
    t.string   "comparison_table_column"
    t.string   "comparison_table_scope_method"
    t.string   "comparison_table_scope_value"
    t.string   "custom_function"
  end

  add_index "rules", ["channel_id"], name: "index_rules_on_channel_id", using: :btree
  add_index "rules", ["strategy_id"], name: "index_rules_on_strategy_id", using: :btree

  create_table "schemes", force: :cascade do |t|
    t.datetime "starting_at"
    t.datetime "ending_at"
    t.string   "state",        default: "inactive"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "strategy_ids", default: [],                      array: true
  end

  add_index "schemes", ["state"], name: "index_schemes_on_state", using: :btree

  create_table "simulations", force: :cascade do |t|
    t.integer  "scheme_id"
    t.integer  "starting_quote_id"
    t.integer  "ending_quote_id"
    t.datetime "completed_at"
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.decimal  "usd_starting_account_balance", precision: 25, scale: 10
    t.decimal  "usd_account_balance",          precision: 25, scale: 10
    t.decimal  "btc_starting_account_balance", precision: 25, scale: 10
    t.decimal  "btc_account_balance",          precision: 25, scale: 10
    t.decimal  "eth_starting_account_balance", precision: 25, scale: 10
    t.decimal  "eth_account_balance",          precision: 25, scale: 10
    t.decimal  "ltc_starting_account_balance", precision: 25, scale: 10
    t.decimal  "ltc_account_balance",          precision: 25, scale: 10
  end

  add_index "simulations", ["scheme_id"], name: "index_simulations_on_scheme_id", using: :btree

  create_table "slack_notifications", force: :cascade do |t|
    t.string   "channel"
    t.integer  "quote_id"
    t.integer  "lookback_in_hours"
    t.integer  "percent_change_threshold"
    t.text     "message"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "currency_pair"
  end

  add_index "slack_notifications", ["quote_id"], name: "index_slack_notifications_on_quote_id", using: :btree

  create_table "strategies", force: :cascade do |t|
    t.string   "name"
    t.datetime "last_alert_sent_at"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "currency_pair"
    t.string   "category"
    t.integer  "trade_percent_of_account_balance"
  end

  add_index "strategies", ["category"], name: "index_strategies_on_category", using: :btree
  add_index "strategies", ["currency_pair"], name: "index_strategies_on_currency_pair", using: :btree

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "channel_id"
    t.string   "notification_type"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "subscriptions", ["channel_id"], name: "index_subscriptions_on_channel_id", using: :btree
  add_index "subscriptions", ["user_id"], name: "index_subscriptions_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "email"
    t.string   "password_digest"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.boolean  "verified"
    t.string   "verification_token"
    t.datetime "verification_sent_at"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "slug"
    t.string   "auth_token"
    t.boolean  "password_is_user_generated", default: true
    t.string   "last_sign_in_ip"
    t.boolean  "admin",                      default: false
    t.boolean  "subscribed",                 default: true
  end

  add_index "users", ["auth_token"], name: "index_users_on_auth_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["slug"], name: "index_users_on_slug", unique: true, using: :btree

  create_table "wallets", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end

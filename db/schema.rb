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

ActiveRecord::Schema.define(version: 2020_07_15_204032) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "calendars", force: :cascade do |t|
    t.date "day"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "debenture_market_data", force: :cascade do |t|
    t.float "rate"
    t.float "credit_spread"
    t.bigint "calendar_id"
    t.bigint "debenture_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "price"
    t.float "days_to_maturity"
    t.index ["calendar_id"], name: "index_debenture_market_data_on_calendar_id"
    t.index ["debenture_id"], name: "index_debenture_market_data_on_debenture_id"
  end

  create_table "debentures", force: :cascade do |t|
    t.string "code"
    t.bigint "issuer_id"
    t.date "issuance_date"
    t.date "maturity_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "rate_type"
    t.string "index"
    t.index ["issuer_id"], name: "index_debentures_on_issuer_id"
  end

  create_table "index_market_data", force: :cascade do |t|
    t.float "rate"
    t.bigint "calendar_id"
    t.bigint "index_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calendar_id"], name: "index_index_market_data_on_calendar_id"
    t.index ["index_id"], name: "index_index_market_data_on_index_id"
  end

  create_table "indices", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "issuers", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "sector_id"
    t.index ["sector_id"], name: "index_issuers_on_sector_id"
  end

  create_table "sectors", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "debenture_market_data", "calendars"
  add_foreign_key "debenture_market_data", "debentures"
  add_foreign_key "debentures", "issuers"
  add_foreign_key "index_market_data", "calendars"
  add_foreign_key "index_market_data", "indices"
  add_foreign_key "issuers", "sectors"
end

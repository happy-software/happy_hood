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

ActiveRecord::Schema.define(version: 2021_05_07_034604) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "home_owners_associations", force: :cascade do |t|
    t.boolean "active"
    t.string "name"
    t.string "email"
    t.string "phone"
    t.string "website"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "hood_id"
    t.index ["active"], name: "index_home_owners_associations_on_active"
    t.index ["hood_id"], name: "index_home_owners_associations_on_hood_id"
  end

  create_table "hoods", force: :cascade do |t|
    t.string "name"
    t.string "zip_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["zip_code"], name: "index_hoods_on_zip_code"
  end

  create_table "house_metadata", force: :cascade do |t|
    t.float "garage_count"
    t.float "bedrooms"
    t.float "bathrooms"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "zpid"
    t.bigint "house_id"
    t.float "square_feet"
    t.index ["house_id"], name: "index_house_metadata_on_house_id"
  end

  create_table "house_prices", force: :cascade do |t|
    t.datetime "valuation_date"
    t.string "source"
    t.float "price"
    t.jsonb "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "house_id"
    t.index ["house_id"], name: "index_house_prices_on_house_id"
  end

  create_table "houses", force: :cascade do |t|
    t.jsonb "address"
    t.bigint "hood_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "price_history"
    t.index ["hood_id"], name: "index_houses_on_hood_id"
  end

  create_table "news_posts", force: :cascade do |t|
    t.string "title"
    t.datetime "post_date"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "home_owners_associations", "hoods"
  add_foreign_key "house_metadata", "houses"
  add_foreign_key "house_prices", "houses"
  add_foreign_key "houses", "hoods"
end

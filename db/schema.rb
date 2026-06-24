# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_24_213558) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "book_tags", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.datetime "created_at", null: false
    t.bigint "tag_id", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id", "tag_id"], name: "index_book_tags_on_book_id_and_tag_id", unique: true
    t.index ["book_id"], name: "index_book_tags_on_book_id"
    t.index ["tag_id"], name: "index_book_tags_on_tag_id"
  end

  create_table "books", force: :cascade do |t|
    t.string "age_indicator"
    t.string "author"
    t.decimal "cached_average_rating", default: "0.0", null: false
    t.string "country_of_origin"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "isbn"
    t.string "language"
    t.integer "page_count"
    t.integer "published_year"
    t.integer "ratings_count", default: 0, null: false
    t.integer "recommendation_count", default: 0, null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["isbn"], name: "index_books_on_isbn", unique: true
  end

  create_table "favorite_books", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.datetime "created_at", null: false
    t.integer "position"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["book_id", "user_id"], name: "index_favorite_books_on_book_id_and_user_id", unique: true
    t.index ["book_id"], name: "index_favorite_books_on_book_id"
    t.index ["user_id"], name: "index_favorite_books_on_user_id"
  end

  create_table "loans", force: :cascade do |t|
    t.bigint "book_id"
    t.string "book_title"
    t.string "counterparty_name"
    t.datetime "created_at", null: false
    t.integer "direction"
    t.date "loaned_on"
    t.text "notes"
    t.date "returned_on"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["book_id"], name: "index_loans_on_book_id"
    t.index ["user_id"], name: "index_loans_on_user_id"
  end

  create_table "map_entries", force: :cascade do |t|
    t.boolean "auto_filled", default: false, null: false
    t.bigint "book_id"
    t.string "color"
    t.string "country_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["book_id"], name: "index_map_entries_on_book_id"
    t.index ["user_id", "country_code"], name: "index_map_entries_on_user_id_and_country_code", unique: true
    t.index ["user_id"], name: "index_map_entries_on_user_id"
  end

  create_table "ratings", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.datetime "created_at", null: false
    t.text "review"
    t.integer "score", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["book_id"], name: "index_ratings_on_book_id"
    t.index ["user_id", "book_id"], name: "index_ratings_on_user_id_and_book_id", unique: true
    t.index ["user_id"], name: "index_ratings_on_user_id"
  end

  create_table "reading_entries", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.text "citation"
    t.datetime "created_at", null: false
    t.text "discovery_source"
    t.date "finished_at"
    t.text "notes"
    t.date "started_at"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["book_id"], name: "index_reading_entries_on_book_id"
    t.index ["user_id", "book_id"], name: "index_reading_entries_on_user_id_and_book_id", unique: true
    t.index ["user_id"], name: "index_reading_entries_on_user_id"
  end

  create_table "reading_sessions", force: :cascade do |t|
    t.bigint "book_id"
    t.datetime "created_at", null: false
    t.integer "duration_minutes"
    t.text "notes"
    t.integer "pages_read"
    t.date "read_on"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["book_id"], name: "index_reading_sessions_on_book_id"
    t.index ["user_id"], name: "index_reading_sessions_on_user_id"
  end

  create_table "recommendation_list_items", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.datetime "created_at", null: false
    t.text "note"
    t.integer "position"
    t.bigint "recommendation_list_id", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_recommendation_list_items_on_book_id"
    t.index ["recommendation_list_id", "book_id"], name: "idx_on_recommendation_list_id_book_id_5d3e2487d8", unique: true
    t.index ["recommendation_list_id"], name: "index_recommendation_list_items_on_recommendation_list_id"
  end

  create_table "recommendation_lists", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "public", default: false, null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_recommendation_lists_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.text "bio"
    t.datetime "created_at", null: false
    t.boolean "eink_mode", default: false, null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "book_tags", "books"
  add_foreign_key "book_tags", "tags"
  add_foreign_key "favorite_books", "books"
  add_foreign_key "favorite_books", "users"
  add_foreign_key "loans", "books"
  add_foreign_key "loans", "users"
  add_foreign_key "map_entries", "books"
  add_foreign_key "map_entries", "users"
  add_foreign_key "ratings", "books"
  add_foreign_key "ratings", "users"
  add_foreign_key "reading_entries", "books"
  add_foreign_key "reading_entries", "users"
  add_foreign_key "reading_sessions", "books"
  add_foreign_key "reading_sessions", "users"
  add_foreign_key "recommendation_list_items", "books"
  add_foreign_key "recommendation_list_items", "recommendation_lists"
  add_foreign_key "recommendation_lists", "users"
  add_foreign_key "sessions", "users"
end

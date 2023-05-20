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

ActiveRecord::Schema[7.0].define(version: 2023_05_20_145436) do
  create_table "images", force: :cascade do |t|
    t.string "url", null: false
    t.integer "user_id", null: false
    t.string "caption"
    t.string "date_time"
    t.float "f_number"
    t.float "focal_length_in_35mm_film"
    t.float "gps_altitude"
    t.float "gps_latitude"
    t.float "gps_longitude"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.string "email", null: false
    t.string "password", null: false
    t.string "avatar"
  end

  add_foreign_key "images", "users"
end

class SetNewSchema < ActiveRecord::Migration[7.0]
  def change
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
    end
  
    add_foreign_key "images", "users"
  end
end

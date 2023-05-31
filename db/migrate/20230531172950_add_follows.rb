class AddFollows < ActiveRecord::Migration[7.0]
  def change
    create_table "follows", force: :cascade do |t|
      t.integer "follower_id", null: false
      t.integer "followee_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["follower_id", "followee_id"], unique: true
    end
    add_foreign_key "follows", "users", column: "followee_id"
    add_foreign_key "follows", "users", column: "follower_id"
  end
end

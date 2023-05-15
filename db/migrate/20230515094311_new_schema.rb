class NewSchema < ActiveRecord::Migration[7.0]
  def change
    create_table "users", force: :cascade do |t|
      t.string "username", null: false
      t.string "email", null: false
      t.string "password", null: false
    end
  end
end

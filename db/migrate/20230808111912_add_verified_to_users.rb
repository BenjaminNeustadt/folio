class AddVerifiedToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users , :verified_account, :boolean, default: false, null: false
  end
end

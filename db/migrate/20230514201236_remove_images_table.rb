class RemoveImagesTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :images
  end
end

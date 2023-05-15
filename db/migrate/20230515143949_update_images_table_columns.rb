class UpdateImagesTableColumns < ActiveRecord::Migration[7.0]
  def change
    add_column :images, :date_time, :string
    add_column :images, :f_number, :float
    add_column :images, :focal_length_in_35mm_film, :float
    add_column :images, :gps_altitude, :float
    add_column :images, :gps_latitude, :float
    add_column :images, :gps_longitude, :float
  end
end

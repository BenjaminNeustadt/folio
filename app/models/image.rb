class Image < ActiveRecord::Base
  belongs_to :user

  ## Tentative, make the model look pretty
  #
  # def initialize(file, url, caption)
  #   file = File.open(file)
  #   @url = url
  #   @caption = caption
  # end
  # # :TODO: this belongs inside the model
  # def image_data
  #   {
  #     url: @url,
  #     user_id: @user_id,
  #     caption: @caption,
  #     date_time: @date_time,
  #     gps_latitude: @gps_latitude,
  #     gps_longitude: @gps_longitude
  #   }
  # end
end

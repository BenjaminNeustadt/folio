
# :TODO: make the modules classes instead
module ImageMetaDataJSONHelper

  def image_data_to_json(images = Image.all)
    content_type :json

    username = params[:username]
    user = User.find_by(username: username)

    images_data = []

    if user
      images = user.images
    else
      images = Image.all
    end

    images.each do |image|
      image_link = "<img src='" + image.url + "' style='max-width: 200px; max-height: 200px;'>"
      images_data << {
        latitude: image.gps_latitude,
        longitude: image.gps_longitude,
        label: image.caption,
        tooltip: image_link
      }
    end
    images_data.to_json
  end

end

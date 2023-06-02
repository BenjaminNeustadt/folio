
module ImageHelper

  def prepare_image
    # Get the user_id from the session
    @user_id   = session[:user_id]
    # get the file
    @file      = params[:file][:tempfile]
    @caption   = params[:caption]
  end

  # :TODO: this belongs inside the model
  def image_data
    {
      url: @url,
      user_id: @user_id,
      caption: @caption,
      date_time: @date_time,
      gps_latitude: @gps_latitude,
      gps_longitude: @gps_longitude
    }
  end

  def process_image
    prepare_image
    extract_exif_data(@file)
  end

end
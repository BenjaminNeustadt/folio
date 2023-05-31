require_relative '../models/image'

module EXIFReaderHelper

  def convert_gps_coordinates(coordinate)
    degrees = coordinate[0].numerator.to_f / coordinate[0].denominator
    minutes = coordinate[1].numerator.to_f / coordinate[1].denominator / 60
    seconds = coordinate[2].numerator.to_f / coordinate[2].denominator / 3600
    
    decimal_coordinate = degrees + minutes + seconds
    decimal_coordinate
  end

  def extract_exif_data(file)
    data = Exif::Data.new(File.open(file))
    @date_time = data.date_time
    @gps_longitude = convert_gps_coordinates(data.gps_longitude)
    @gps_latitude = convert_gps_coordinates(data.gps_latitude)
  end

end

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

module ImageController
  include EXIFReaderHelper
  include ImageHelper

  def all_images
    Image.all
  end

  def delete_image
     Image.find(params[:id]).destroy
   end

  def upload_to_cloud_storage(file, file_name)
    # Upload file to AWS S3
    object = settings.bucket.object(file_name)
    object.upload_file(file)
    @url = object.public_url.to_s
  end

  def store_image
    process_image
    upload_to_cloud_storage(@file, params[:file][:filename])
    Image.create(image_data)
  end

end
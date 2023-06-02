require_relative '../models/image'
require_relative './lib/exif_reader_helper'
require_relative './lib/image_helper'



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

require_relative '../models/image'

module ImageController

  def all_images
    Image.all
  end

  def delete_image
     Image.find(params[:id]).destroy
   end

end
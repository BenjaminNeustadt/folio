require 'dotenv/load'

require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/flash'
require 'sinatra/partial'

require 'sinatra/activerecord'
require_relative 'app/models/user'
require_relative 'app/models/image'
require 'bcrypt'

require 'exif'
require 'net/http'
require 'mapkick'

# :TODO: move these controllers to /controllers folder
# :TODO: make the modules classes instead

module UserController

  def current_user
    User.find(session[:user_id]) if session[:user_id]
  end

  def all_users
    @users = User.all
  end

  def sign_up_user
    User.create(
      email: params[:email],
      password: params[:password], 
      username: params[:username]
    )
    redirect '/'
  end
  
  def sign_in_user
    user = User.find_by(email: params[:email])

    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      flash[:notice] = "Welcome to folio #{user.username}!"
      redirect '/account_page'
    else
      flash[:notice] = "Incorrect email or password"
      redirect '/'
    end
  end

  def logout_current_user
    session.clear
    flash[:notice] = "Until the next..."
    redirect '/'
  end

  def search_user
    @user = User.find_by(username: params[:username])

    if @user
      @images = @user.images
      erb(:user_profile)
    else
      flash[:notice] = 'User not found'
      redirect '/account_page'
    end
  end

  def user_has_session?
    if session[:user_id].nil?
      return redirect('/')
    else
      @user  = session[:user_id]
      return erb(:account_page)
    end
  end

end

module ImageController

  def all_images
    Image.all
  end

  def display_map_page
    erb(:map_page)
  end

  # def image_data_to_json
  #   content_type :json

  #   images_data = []

  #   images = Image.all
  #   images.each do |image|
  #   image_link = "<img src='" + image.url + "' style='max-width: 200px; max-height: 200px;'>"
  #     images_data << {
  #       latitude: image.gps_latitude,
  #       longitude: image.gps_longitude,
  #       label: image.caption,
  #       tooltip: image_link
  #     }
  #   end
  #   images_data.to_json
  # end

  def delete_image
    Image.find(params[:id]).destroy
    redirect '/account_page'
  end

  def upload_image
    # Get the user_id from the session
    user_id = session[:user_id]
    # get the file
    file = params[:file][:tempfile]
    data = Exif::Data.new(File.open(file))
    date_time = data.date_time
    gps_longitude = convert_gps_coordinates(data.gps_longitude)
    gps_latitude = convert_gps_coordinates(data.gps_latitude)
    # Get the file name and caption
    file_name = params[:file][:filename]
    caption = params[:caption]

    # Upload file to AWS S3
    object = settings.bucket.object(file_name)
    object.upload_file(file)
    url = object.public_url.to_s

    image_params = {
      url: url,
      user_id: user_id,
      caption: caption,
      date_time: date_time,
      gps_latitude: gps_latitude,
      gps_longitude: gps_longitude
    }
    # create the image associated with the user
    Image.create(image_params)
    redirect '/account_page'
  end

  # :TODO: put this in ExifHelpers module
  def convert_gps_coordinates(coordinate)
    degrees = coordinate[0].numerator.to_f / coordinate[0].denominator
    minutes = coordinate[1].numerator.to_f / coordinate[1].denominator / 60
    seconds = coordinate[2].numerator.to_f / coordinate[2].denominator / 3600
    
    decimal_coordinate = degrees + minutes + seconds
    decimal_coordinate
  end

end

class Application < Sinatra::Base
  instance_eval(File.read('config/config.rb'))

  include UserController
  include ImageController

  enable :sessions
  register Sinatra::Flash
  register Sinatra::Partial

  enable :partial_underscores
  set :partial_template_engine, :erb

  # create instance variables to pass to views
  before do
    @current_user = current_user
    @current_page = request.path_info
    @images = all_images
    @users = all_users
    @bucket = settings.s3.bucket('folio-test-bucket')
    @bucket_objects = @bucket.objects.to_a rescue []  # rescue empty array if bucket does not exist or is empty
  end

  get '/' do
    erb(:account_page)
  end

  post('/users/sign_up') { sign_up_user } 

  # search for an indepenedent user's feed/page
  post('/users/sign_in') { sign_in_user }

  get('/users/:username') { search_user }

  get('/account_page') { user_has_session? }

  post('/upload') { upload_image }

  # :TODO: use 'delete' instead of 'post'
  post('/images/:id') { delete_image }

  def image_data_to_json(images = Image.all)
    content_type :json

    images_data = []

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

  get('/images_data.json') { image_data_to_json(@current_user.images) }

  get('/map_page') { display_map_page }

  get('/logout') { logout_current_user }

  get('/shop_page') { erb(:shop_page) }

end
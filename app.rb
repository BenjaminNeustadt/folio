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


end

module ImageController

end

class Application < Sinatra::Base
  instance_eval(File.read('config/config.rb'))

  include UserController
  include ImageController

  enable :sessions
  register Sinatra::Flash
  register Sinatra::Partial

  mime_type :js, 'application/javascript'


  def current_user
    User.find(session[:user_id]) if session[:user_id]
  end

  def all_users
    @users = User.all
  end

  def search_bar
    search_query = params[:search_query]
    @matched_users = User.where("username LIKE ?", "%#{search_query}%")
    erb(:search_results, layout: false)
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
      redirect '/'
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

  def all_images
    Image.all
  end

  #(?) not certain if this is in the correct scope
  def current_user_images
    current_user.images rescue []
  end

  def delete_image
    Image.find(params[:id]).destroy
    redirect '/'
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
    redirect '/'
  end

  # :TODO: put this in ExifHelpers module
  def convert_gps_coordinates(coordinate)
    degrees = coordinate[0].numerator.to_f / coordinate[0].denominator
    minutes = coordinate[1].numerator.to_f / coordinate[1].denominator / 60
    seconds = coordinate[2].numerator.to_f / coordinate[2].denominator / 3600
    
    decimal_coordinate = degrees + minutes + seconds
    decimal_coordinate
  end


  enable :partial_underscores
  set :partial_template_engine, :erb

  # create instance variables to pass to views
  before do
    @current_user = current_user
    @current_page = request.path_info
    @images = all_images
    @user_images = current_user_images
    @users = all_users
    @bucket = settings.s3.bucket('folio-test-bucket')
    @bucket_objects = @bucket.objects.to_a rescue []  # rescue empty array if bucket does not exist or is empty
  end

  get '/' do
    if session[:user_id]
      @user = session[:user_id]
      erb(:account_page)
    else
      redirect('/login')
    end
  end

  get '/login' do
      erb(:login_page)
  end

  post('/users/sign_up') { sign_up_user } 

  # search for an indepenedent user's feed/page
  post('/users/sign_in') { sign_in_user }


  post('/users/search') { search_bar }

  # def search_user
  # end

  get('/users/:username') {
    @user = User.find_by(username: params[:username])

    if @user
      @images = @user.images
      erb(:user_profile)
    else
      flash[:notice] = 'User not found'
      redirect '/'
    end
  }

  # def image_data_to_json(images = Image.all)
  # end
  def image_data_to_json(images = Image.all)
    content_type "application/json"

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

  get('/images_data.json') { image_data_to_json() }

  get('/users/:username/images_data.json') {
    content_type :json
    # content_type 'application/json'

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
  }

  # def display_map_page
  # end

  # get('/users/:username/map_page') {
  #   username = params[:username]
  #   @user = User.find(username: username)

  #   if @user.nil?
  #     flash[:notice] = 'User not Found'
  #     redirect '/'
  #   else
  #     erb(:map_page)
  #   end
  # }
   get('/map_page') {
      erb(:map_page)
   }

  get('/current_user_profile') { erb(:current_user_profile) }

  post('/upload') { upload_image }

  # :TODO: use 'delete' instead of 'post'
  post('/images/:id') { delete_image }

  get('/logout') { logout_current_user }

  # get('/shop_page') { erb(:shop_page) }

end
require 'dotenv/load'

require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/flash'
require 'sinatra/partial'
require 'sinatra/activerecord'

require_relative 'app/controllers/user'
require_relative 'app/controllers/image'

require_relative 'app/models/user'
require_relative 'app/models/image'

require 'bcrypt'

require 'exif'
require 'net/http'
require 'mapkick'

# :TODO: make the modules classes instead

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
    @user_images = current_user_images
    @users = all_users
    @bucket = settings.s3.bucket('folio-test-bucket')
    @bucket_objects = @bucket.objects.to_a rescue []  # rescue empty array if bucket does not exist or is empty
  end
  # mime_type :js, 'application/javascript'

  def search_bar
    search_query = params[:search_query]
    @matched_users = User.where("username LIKE ?", "%#{search_query}%")
    erb(:search_results, layout: false)
  end


  def logout_current_user
    session.clear
    flash[:notice] = "Until the next..."
    redirect '/'
  end


  #(?) not certain if this is in the correct scope
  def current_user_images
    current_user.images rescue []
  end

  # def delete_image
  #   Image.find(params[:id]).destroy
  #   redirect '/'
  # end


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

  post('/users/sign_up') {
    sign_up_user
    redirect '/'
  } 

  post('/users/sign_in') {
    sign_in_user
    redirect '/'
  }

  post('/users/search') { search_bar }

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

   get('/map_page') {
      erb(:map_page)
   }

  get('/current_user_profile') { erb(:current_user_profile) }


  # :TODO: put this in ExifHelpers module

  post('/upload') {
    store_image

    redirect '/'
  }

  # :TODO: use 'delete' instead of 'post'
  post('/images/:id') {
    delete_image
    
  }

  get('/logout') { logout_current_user }

end
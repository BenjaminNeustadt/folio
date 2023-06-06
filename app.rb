require 'dotenv/load'

require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/flash'
require 'sinatra/partial'
require 'sinatra/activerecord'

require_relative 'app/controllers/user_controller'
require_relative 'app/controllers/image_controller'
require_relative 'app/controllers/follows_controller'

require_relative 'app/models/user'
require_relative 'app/models/image'
require_relative 'app/models/follow'

require_relative 'app/controllers/lib/image_meta_data_json_helper'

require 'bcrypt'

require 'exif'
require 'net/http'
require 'mapkick'

class Application < Sinatra::Base
  instance_eval(File.read('config/config.rb'))

  include FollowsController
  include UserController
  include ImageController
  include ImageMetaDataJSONHelper

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

  #(?) not certain if this is in the correct scope
  def current_user_images
    current_user.images rescue []
  end

  # FOLLOW
  post('/users/:user_id/follow/:followee_id'){
    set_followee(params[:followee_id])
    set_follower(params[:user_id])
    follow
    response.body = { status: 'success - user followed' }.to_json
    redirect back
  }

  # UNFOLLOW
  post('/users/:user_id/unfollow/:followee_id'){
    set_followee(params[:followee_id])
    set_follower(params[:user_id])
    unfollow
    response.body = { status: 'success - user unfollowed' }.to_json
    redirect back
  }

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

  #==================== 
  # SETTINGS FOR USER
  #==================== 

  get '/settings' do
    erb :settings
  end

  post '/settings' do
    if @current_user.update(background_color: params[:background_color])
      flash[:notice] = 'Background color saved.'
    else
      flash[:error] = 'Failed to save background color.'
    end
    redirect '/settings'
  end

  get '/all_users' do
    erb(:all_users)
  end

  post('/users/sign_up') {
    sign_up_user
    redirect '/'
  } 

  post('/users/sign_in') {
    sign_in_user
    redirect '/'
  }


  post('/users/search') {
    search_query = params[:search_query]
    @matched_users = User.where("username LIKE ?", "%#{search_query}%")
    erb(:search_results, layout: false)
  }

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

  get('/images_data.json') {
    image_data_to_json()
  }

  # :TODO: think about whether you need both this and the above

  get('/users/:username/images_data.json') {
    image_data_to_json()
  }

   get('/map_page') {
      erb(:map_page)
   }

  get('/current_user_profile') {
    erb(:current_user_profile)
  }

  # :TODO: put this in ExifHelpers module

  post('/upload') {
    store_image
    redirect '/'
  }

  # :TODO: use 'delete' instead of 'post'
  post('/images/:id') {
    delete_image
  }

  get('/logout') {
    session.clear
    flash[:notice] = "Until the next..."
    redirect '/'
  }

end

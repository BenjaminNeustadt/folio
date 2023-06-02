require 'dotenv/load'

require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/flash'
require 'sinatra/partial'
require 'sinatra/activerecord'

require_relative 'app/controllers/user_controller'
require_relative 'app/controllers/image_controller'

require_relative 'app/models/user'
require_relative 'app/models/image'

require_relative 'app/controllers/lib/image_meta_data_json_helper'
# require_relative 'app/controllers/follows_controller'

require 'bcrypt'

require 'exif'
require 'net/http'
require 'mapkick'

# How to put this instead of a module?
module FollowsController
  # before_action :set_followee, :set_follower
  # rescue_from ActiveRecord::RecordInvalid, with: :handle_error

  def handle_error error
    render json: { error: error.message }, status: :unprocessable_entity
  end

  # POST users/:user_id/follow/:user_id
  def follow
    @follower.followees << @followee
    render json: { status: 'success - user followed'}
  end

  # POST users/:user_id/unfollow/:user_id
  def unfollow
    @follower.followees.delete(@followee)
    render json: { status: 'success - user unfollowed'}
  end

  private

  def set_followee
    @followee = User.find(params[:followee_id])
  end

  def set_follower
    @follower = User.find(params[:user_id])
  end
end

class Application < Sinatra::Base
  instance_eval(File.read('config/config.rb'))

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
  # mime_type :js, 'application/javascript'

  # FOLLOW
  def follow
    @follower.followees << @followee
    render json: { status: 'success - user followed'}
  end
  post('/users/:user_id/follow/:followee_id'){
    follow
  }

  def unfollow
    @follower.followees.delete(@followee)
    render json: { status: 'success - user unfollowed'}
  end
  # UNFOLLOW
  post('/users/:user_id/unfollow/:followee_id'){
    unfollow
  }
  #(?) not certain if this is in the correct scope
  def current_user_images
    current_user.images rescue []
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

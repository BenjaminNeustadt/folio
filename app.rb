
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

class Application < Sinatra::Base
  instance_eval(File.read('config/config.rb'))

  # the order of these is important
  enable :sessions
  register Sinatra::Flash
  register Sinatra::Partial

  enable :partial_underscores
  set :partial_template_engine, :erb

  # :TODO: maybe just put these inside their respetive models,
  # since these are interacting with the database so that's where they should be.
  before do
    @current_user = User.find(session[:user_id]) if session[:user_id]
    @current_page = request.path_info
    @images = Image.all
    @users = User.all
    @bucket = settings.s3.bucket('folio-test-bucket')
    @bucket_objects = @bucket.objects.to_a rescue []  # rescue empty array if bucket does not exist or is empty
  end

  get '/' do
    # @current_page = '/'
    # @user  = session[:user_id]
    # @users = User.all.to_json
    # @users = User.all
    erb(:sign_up)
  end

  # :TODO: put the User.create inside the model also
  post '/users/sign_up' do
    User.create(
      email: params[:email],
      password: params[:password], 
      username: params[:username]
    )
    redirect '/'
  end

  post '/users/sign_in' do
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

  # search for an indepenedent user's feed/page
  get '/users/:username' do
    # @current_page = '/users/:username'
    @user = User.find_by(username: params[:username])

    if @user
      @images = @user.images
      erb(:user_profile)
    else
      flash[:notice] = 'User not found'
      redirect '/account_page'
    end
  end

  # This is the special account page
  get '/account_page' do
    # @current_page = '/account_page'
    if session[:user_id].nil?
      return redirect('/')
    else
      @user  = session[:user_id]
      # @current_user = User.find(session[:user_id])
      # @images = Image.all
      # @bucket = settings.s3.bucket('folio-test-bucket')
      # @bucket_objects = @bucket.objects.to_a rescue []  # rescue empty array if bucket does not exist or is empty
      # @users = User.all.to_json
      # @users = User.all
      return erb(:account_page)
    end
  end

  # :TODO: put this in ExifHelpers module
  def convert_gps_coordinates(coordinate)
    degrees = coordinate[0].numerator.to_f / coordinate[0].denominator
    minutes = coordinate[1].numerator.to_f / coordinate[1].denominator / 60
    seconds = coordinate[2].numerator.to_f / coordinate[2].denominator / 3600
    
    decimal_coordinate = degrees + minutes + seconds
    decimal_coordinate
  end

  # IMAGE UPLOAD
  post '/upload' do
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

  # :TODO: use 'delete' instead of 'post'
  # deleting an image
  post '/images/:id' do
    Image.find(params[:id]).destroy
    redirect '/account_page'
  end

  get '/images_data.json' do
    content_type :json

    images_data = []

    images = Image.all
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

  get '/map_page' do
    @test_image = Image.all.last
    # @current_page = '/map_page'
    erb(:map_page)
  end

  get '/logout' do
    session.clear
    flash[:notice] = "Until the next..."
    redirect '/'
  end

  get '/shop_page' do
    erb(:shop_page)
  end

end
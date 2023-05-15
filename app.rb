require 'dotenv/load'

require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/flash'

require 'sinatra/activerecord'
require_relative 'app/models/user'
require_relative 'app/models/image'
require 'bcrypt'

require 'exif'
require 'aws-sdk-s3'
require 'net/http'


class User < ActiveRecord::Base

  before_save :encrypt_password

  private

  def encrypt_password
    self.password = BCrypt::Password.create(password)
  end

  public

  def authenticate(password)
    BCrypt::Password.new(self.password) == password
  end

end

class Image < ActiveRecord::Base
  belongs_to :user
  # include CloudHelpers
end

class Application < Sinatra::Base
  # Allow code to refresh without having to restart server
  configure :development do
    register Sinatra::Reloader
    Aws.config.update({
    region: 'eu-north-1',
    credentials: Aws::Credentials.new(ENV['S3_ACCESS_KEY'], ENV['S3_SECRET_KEY'])
    })

    set :s3, Aws::S3::Resource.new
    set :bucket, settings.s3.bucket('folio-test-bucket')
  end

  enable :sessions
  register Sinatra::Flash

  get '/' do
    @users = User.all.to_json
    erb(:sign_up)
  end

  post '/users/sign_up' do
    User.create(email: params[:email], password:params[:password] , username: params[:username])
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

  # This is the special account page
  get '/account_page' do
    if session[:user_id].nil?
      return redirect('/')
    else
      @images = Image.all
      @bucket = settings.s3.bucket('folio-test-bucket')
      @bucket_objects = @bucket.objects.to_a rescue []  # rescue empty array if bucket does not exist or is empty
      @users = User.all.to_json
      return erb(:account_page)
    end
  end

  # IMAGE UPLOAD
  post '/upload' do
    # Get the user_id from the session
    user_id = session[:user_id]
    # Get the file name and caption
    file_name = params[:file][:filename]
    caption = params[:caption]

    # Upload file to AWS S3
    obj = settings.bucket.object(file_name)
    url = obj.public_url.to_s

    uri = URI.parse(url)
    file_content = Net::HTTP.get(uri)

    data = Exif::Data.new(file_content)
    date_time = data.date_time

    # create the image associated with the user
    Image.create(url: url, user_id: user_id, caption: caption, date_time: date_time)
  end

  post '/images/:id' do
    Image.find(params[:id]).destroy
    redirect '/account_page'
  end

end

require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/flash'

require 'sinatra/activerecord'
require_relative 'app/models/user'
require_relative 'app/models/image'
require 'bcrypt'

class User < ActiveRecord::Base

end

class Application < Sinatra::Base

  # Allow code to refresh without having to restart server
  configure :development do
    register Sinatra::Reloader
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

    if user && user.password == params[:password]
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
      @users = User.all.to_json
      return erb(:account_page)
    end
  end

end

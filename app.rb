require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require_relative 'app/models/user'
require_relative 'app/models/image'
require 'bcrypt'

class User < ActiveRecord::Base

  # def create(new_user)
  #   encrypted_password = BCrypt::Password.create(new_user.password)
  #   (email: new_user.email , password: encrypted_password, username: new_user.username, user_id: new_user.user_id)
  # end

end

class Application < Sinatra::Base

  # Allow code to refresh without having to restart server
  configure :development do
    register Sinatra::Reloader
  end

    # new_user = {email: params[:email], password: params[:password], username: params[:username]}
    # encrypted_password = BCrypt::Password.create(new_user.password)
    # # User.create(email: 'example@email.com', password: encrypted_password, username: 'Example', user_id: 12 )
    # User.create(email: new_user.email, password: encrypted_password, username: new_user.username , user_id: 12 )
    # @all_users = User.all.to_json

  get '/' do
    @users = User.all.to_json
    erb(:sign_up)
  end

  post '/users/sign_up' do
    User.create(email: params[:email], password:params[:password] , username: params[:username])
    redirect '/'
  end

  # Routes for user signup

end

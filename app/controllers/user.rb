require_relative '../models/user'

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
  end

end
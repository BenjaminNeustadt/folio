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

  def sign_in_user
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      flash[:notice] = "Welcome to folio #{user.username}!"
    else
      flash[:notice] = "Incorrect email or password"
    end
  end

end
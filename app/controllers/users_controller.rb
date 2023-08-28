require_relative '../models/user'

require 'sendgrid-ruby'
require 'dotenv/load'

module UsersController
include SendGrid

  def current_user
    User.find(session[:user_id]) if session[:user_id]
  end

  def all_users
    @users = User.all
  end

  def sign_up_user
      @user = User.create(
      email: params[:email],
      password: params[:password], 
      username: params[:username]
    )
    mail_validation(@user)
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

  def mail_validation(user)
    from = Email.new(email: 'b.james.neustadt@gmail.com')
    to = Email.new(email: user.email)
    subject = 'Sending with SendGrid is Fun'
    
  # email_body = "Hello #{user.username}, Click on this button to verify your account /button/"
  # Construct the HTML content with a button

  email_body = <<~HTML
  <p>Hello #{user.username},</p>
  <p>Click the button below to verify your account:</p>
  <a href="https://www.example.com/verify/#{user.id}" style="display: inline-block; padding: 10px 20px; background-color: #007bff; color: white; text-decoration: none; border-radius: 5px;">Verify Account</a>
HTML

    
    content = Content.new(type: 'text/html', value: email_body)
    mail = Mail.new(from, subject, to, content)
    
    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    
    response = sg.client.mail._('send').post(request_body: mail.to_json)
    puts response.status_code
    puts response.body
    puts response.headers
  end


end
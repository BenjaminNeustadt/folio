# require 'sinatra'
# require 'sendgrid-ruby'
# post '/completed' do
#   from = Email.new(email: "joseph@mysite.com")
#   to = Email.new(email: @my_email)
#   subject = "Welcome aboard, #{@my_first_name} #{@my_last_name}!"
#   content = Content.new(type: "text/plain", value: "Welcome aboard #{@my_first_name} #{@my_last_name}. We're so excited to have you on board with us, along with all your co-workers at #{@company}!")
#   mail = Mail.new(from, subject, to, content)
#   sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
#   response = sg.client.mail._('send').post(request_body: mail.to_json)
#   puts response.status_code
#   puts response.body
#   puts response.headers
#   erb :completed
# end

# using SendGrid's Ruby Library
# https://github.com/sendgrid/sendgrid-ruby
require 'sendgrid-ruby'
require 'dotenv/load'
include SendGrid

# user = User.find_by(email: params[:email])
from = Email.new(email: 'b.james.neustadt@gmail.com')
to = Email.new(email: 'b.james.neustadt@gmail.com')
subject = 'Sending with SendGrid is Fun'

# content = "Click on this button to verify your account #{button}"

user = "Benjamin"

email_body =
 <<~HTML
<p>Hello #{user},</p>
<p>Click the button below to verify your account:</p>
<a href="http:localhost:3000/" style="display: inline-block; padding: 10px 20px; background-color: #007bff; color: white; text-decoration: none; border-radius: 5px;">Verify Account</a>
HTML

# going to button i

get('/verification_of_user/:user_id'){
  verify_user(params[:user_id])
}

def verify_user(user_id)
  user = User.find(user_id).update
  user.update.verified_account
end

content = Content.new(type: 'text/html', value: email_body )
mail = Mail.new(from, subject, to, content)

puts ENV['SENDGRID_API_KEY']

sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])

response = sg.client.mail._('send').post(request_body: mail.to_json)
puts response.status_code
puts response.body
puts response.headers

#========================================================================================== 
# NOTES FOR FUTURE IMPLEMENTATION
#========================================================================================== 
# As a verification method, create a field on database model that is initially set to false. 
# A user cannot do anything unless the verification is switched to true.
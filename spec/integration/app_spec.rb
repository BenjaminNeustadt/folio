require 'spec_helper'
require 'rack/test'
require_relative '../../app'
require 'database_cleaner'

describe Application do
  include Rack::Test::Methods

  let(:app) { Application.new }

  context "GET to /" do
    it "returns 200 OK with the right content" do
      response = get("/")
      expect(response.status).to eq(302)
    end
  end

  context 'sign_up' do
    it 'creates a new account for a user' do
      response = post '/users/sign_up', { email: 'test@example.com', password: 'password', username: 'user_uno' }
      expect(response.status).to eq(302) # 302 is status redirect
      expect(User.last.email).to eq('test@example.com') # user was created
    end
  end

  context 'sign_in' do
    it 'allows user to sign in' do
      post '/users/sign_up', { email: 'test@example.com', password: 'password', username: 'user_uno' }
      response = post '/users/sign_in', { email: 'test@example.com', password: 'password', username: 'user_uno' }
      expect(response).to be_redirect
      follow_redirect!
      expect(last_response.body).to include("Account Page")
    end
  end
  
  describe 'visiting /' do
    context 'when Im signed out' do
      it 'I am redirected to the sign-in page' do
        response = get '/'
        expect(response).to be_redirect
      end
    end
    
    context 'when Im signed in' do
      before do
        user = User.create({username: "Jon", email: "email@email.com", password: "1234"})
        env "rack.session", {:user_id=> user.id}
      end
      it 'I can see my account page' do
        response = get '/'
        expect(response.body).to include "Account Page"
      end
    end
  end

  context 'a session only begins after sign in and ends at sign out' do
    it 'does not initially exist' do
      get '/'
      expect(session[:user_id]).to be_nil
    end

    it 'exists after log_in' do
      post '/users/sign_up', { email: 'test@example.com', password: 'password', username: 'user_uno' }
      post '/users/sign_in', { email: 'test@example.com', password: 'password', username: 'user_uno' }
      # expect(session[:user_id]).to eq(2)
      expect(session[:user_id]).to be_integer
    end

    it 'does not exist after log_out' do
      post '/users/sign_up', { email: 'test@example.com', password: 'password', username: 'user_uno' }
      post '/users/sign_in', { email: 'test@example.com', password: 'password', username: 'user_uno' }
      # :TODO: install data_clean so that this fails
      expect(session[:user_id]).to be_integer
      get '/logout'
      expect(session[:flash][:notice]).to eq "Until the next..."
      expect(session[:user_id]).to be_nil
    end
  end

  context '' do
    it 'does not initially exist' do
      get '/'
      expect(session[:user_id]).to be_nil
    end

    it 'exists after log_in' do
      post '/users/sign_up', { email: 'test@example.com', password: 'password', username: 'user_uno' }
      post '/users/sign_in', { email: 'test@example.com', password: 'password', username: 'user_uno' }
      # expect(session[:user_id]).to eq(1)
      expect(session[:user_id]).to be_integer
    end

    it 'does not exist after log_out' do
      post '/users/sign_up', { email: 'test@example.com', password: 'password', username: 'user_uno' }
      post '/users/sign_in', { email: 'test@example.com', password: 'password', username: 'user_uno' }
      # :TODO: install data_clean so that this fails
      expect(session[:user_id]).to be_integer
      get '/logout'
      expect(session[:flash][:notice]).to eq "Until the next..."
      expect(session[:user_id]).to be_nil
    end
  end

  context 'image upload' do
    it 'creates a new image' do
      # Stub the AWS S3 upload_file method
      allow_any_instance_of(Aws::S3::Object).to receive(:upload_file).and_return(nil)
      # create a user via the browser first; this is required to ge a session id
      post '/users/sign_up', { email: 'test@example.com', password: 'password', username: 'user_uno' }
      post '/users/sign_in', { email: 'test@example.com', password: 'password', username: 'user_uno' }
      get '/'
      # set the session of the user to the current user uploading an image
      post '/upload', { file: Rack::Test::UploadedFile.new(File.join(__dir__, '../../lib/test_images/test_spain.jpeg')), user_id: User.last.id , caption: 'Test Caption' }

      # # Assert that the image was created in the database
      expect(Image.count).to eq(1)
      expect(Image.last.caption).to eq('Test Caption')
    end
  end

  context 'image deletion' do
    it 'deletes an existing image' do
      user = User.create(email: "email.com", password: "password", username: "user")
      image = Image.create(url: 'test_image_url', user_id: user.id, caption: 'Test Image', date_time: Time.now)
      post "/images/#{image.id}"

      expect(Image.exists?(image.id)).to be_falsey
    end
  end

  # :TODO: test for the existant of other attributes like gps

  around do |example|
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.cleaning do
      example.run
    end
  end

end

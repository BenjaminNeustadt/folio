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
      expect(response.status).to eq(200)
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

  context 'a session only begins after sign in and ends at sign out' do
    it 'does not initially exist' do
      get '/'
      expect(session[:user_id]).to be_nil
    end

    it 'exists after log_in' do
      post '/users/sign_up', { email: 'test@example.com', password: 'password', username: 'user_uno' }
      post '/users/sign_in', { email: 'test@example.com', password: 'password', username: 'user_uno' }
      expect(session[:user_id]).to eq(1)
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

  around do |example|
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.cleaning do
      example.run
    end
  end

end

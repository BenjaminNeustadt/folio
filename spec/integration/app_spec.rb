require 'spec_helper'
require 'rack/test'
require_relative '../../app'

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
      expect(User.last.email).to eq('test@example.com') # check that the user was created
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

end

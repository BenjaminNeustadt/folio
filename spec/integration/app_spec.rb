require 'spec_helper'
require 'rack/test'
require_relative '../../app'

describe Application do
  include Rack::Test::Methods

  let(:app) { Application.new }

  context "GET to /" do
    it "returns 200 OK with the right content" do
      # Send a GET request to /
      # and returns a response object we can test.
      response = get("/")

      # Assert the response status code and body.
      expect(response.status).to eq(200)
      # expect(response.body).to eq("FOLIO")
    end

  end

  context 'sign_up' do
    it 'creates a new account for a user' do
      response = post '/users/sign_up', { email: 'test@example.com', password: 'password', username: 'user_uno' }
      # checking for the redirect
      expect(response.status).to eq(302) # check the response status code
      expect(User.last.email).to eq('test@example.com') # check that the user was created
    end
  end
end

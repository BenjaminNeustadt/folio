require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/activerecord'

class Application < Sinatra::Base

  # Allow code to refresh without having to restart server
  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    erb(:index)
  end

end
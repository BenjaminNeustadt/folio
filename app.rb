require 'sinatra/base'
require 'sinatra/reloader'

class FolioApp < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    'Hello'
  end

end
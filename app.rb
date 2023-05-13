require 'sinatra/base'
require 'sinatra/reloader'

class Application < Sinatra::Base

  # Allow code to refresh without having to restart server
  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    'FOLIO'
  end

end
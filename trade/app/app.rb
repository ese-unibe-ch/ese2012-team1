require 'rubygems'
require 'require_relative'
require 'sinatra'
require 'rack/protection'
require 'haml'

require_relative('controllers/authentication')
require_relative('controllers/registration')
require_relative('controllers/sites')
require_relative('controllers/item_actions')
require_relative('controllers/organisation')
require_relative('controllers/uploader')
require_relative('init.rb') unless ENV['RACK_ENV'] == 'test'
require_relative('helpers/render')


include Helpers

class App < Sinatra::Base

  enable :sessions unless ENV['RACK_ENV'] == 'test'
  set :root, File.dirname(__FILE__)
  set :views , "#{absolute_path('/views', __FILE__)}"

  set :public_folder, 'public'
  set :static, true

  #To get userfriendly error messages set this to false
  set :development, true

  use Controllers::Authentication
  use Controllers::Registration
  use Controllers::ItemActions
  use Controllers::Organisation
  use Controllers::Sites
  use Controllers::Uploader

  use Rack::Protection
  set :protection

end

App.run! unless ENV['RACK_ENV'] == 'test'


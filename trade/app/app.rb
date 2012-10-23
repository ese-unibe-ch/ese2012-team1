require 'rubygems'
require 'require_relative'
require 'sinatra'
require 'rack/protection'
require 'haml'
require 'haml/template/options'

require_relative('controllers/authentication')
require_relative('controllers/error')
require_relative('controllers/home')
require_relative('controllers/items')
require_relative('controllers/item_actions')
require_relative('controllers/organisation')
require_relative('controllers/registration')
require_relative('controllers/users')
require_relative('init.rb') unless ENV['RACK_ENV'] == 'test'
require_relative('helpers/render')


include Helpers

class App < Sinatra::Base

  Haml::Template.options[:escape_html] = true

  use Rack::Protection

  enable :sessions unless ENV['RACK_ENV'] == 'test'

  set :root, File.dirname(__FILE__)
  set :views , "#{absolute_path('/views', __FILE__)}"

  set :public_folder, 'public'
  set :static, true

  #To get userfriendly error messages set this to false
  set :development, true

  use Controllers::Home
  use Controllers::Registration
  use Controllers::Authentication
  use Controllers::Error
  use Controllers::Items
  use Controllers::ItemActions
  use Controllers::Organisation
  use Controllers::Users

end

App.run! unless ENV['RACK_ENV'] == 'test'


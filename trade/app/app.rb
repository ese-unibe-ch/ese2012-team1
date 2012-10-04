def relative(path)
  File.join(File.expand_path(File.dirname(__FILE__)), path)
end
require 'rubygems'
require 'require_relative'
require 'sinatra'
require 'haml'
require_relative('controllers/authentication')
require_relative('controllers/sites')
require_relative('controllers/creator')

require_relative('init.rb')

module App
class App

  enable :sessions
  set :views, relative('app/views')
  set :public_folder, 'public'
  set :public, 'public'
  set :static, true
  use Controllers::Authentication
  use Controllers::Creator
  use Controllers::Sites

  get '/hi' do
    "Hello World"
  end


end

end


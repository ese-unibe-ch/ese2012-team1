require 'require'

class App < Sinatra::Base

  Haml::Template.options[:escape_html] = true

  use Rack::Protection

  enable :sessions unless ENV['RACK_ENV'] == 'test'

  set :root, File.dirname(__FILE__)
  set :views , "#{absolute_path('/views', __FILE__)}"

  set :public_folder, 'public'
  set :static, true

  #To set Port on Server
  ##replace_for_port##

  #To get userfriendly error messages set this to false
  set :development, true

  use Controllers::Home
  use Controllers::Error
  use Controllers::Authentication
  use Controllers::Registration
  use Controllers::Search
  use Controllers::ItemActions
  use Controllers::ItemManipulation
  use Controllers::ItemSites
  use Controllers::UserSites
  use Controllers::AccountEdit
  use Controllers::Error
  use Controllers::Organisation
  use Controllers::OrganisationAdmin

  #
  # Create Timer to reset User Buy Limits at 24:00
  # Models::System.instance.reset_all_member_limits
  #

end

App.run! unless ENV['RACK_ENV'] == 'test'


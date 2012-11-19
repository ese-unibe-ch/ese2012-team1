require 'rubygems'
require 'require_relative'
require 'sinatra/base'
require 'haml'
require 'sinatra/content_for'
require_relative('../models/user')
require_relative('../models/item')
require_relative('../helpers/render')

include Models
include Helpers

module Controllers
  class Home < Sinatra::Application
    set :views , "#{absolute_path('../views', __FILE__)}"

    before do
      response.headers['Cache-Control'] = 'public, max-age=0'
    end

    get '/' do
      redirect "/home" if session[:auth]

      #get four random items
      item_list = Models::System.instance.fetch_all_active_items
      return_list = item_list.shuffle[0..3]
      haml :index, :locals => { :items_to_show => return_list }
    end

    get '/home' do
      redirect "/" unless session[:auth]
      if session[:user] == session[:account]
        haml :'home/user'
      else
        admin_view = Models::System.instance.fetch_account(session[:account]).is_admin?(Models::System.instance.fetch_account(session[:user]))
        haml :'home/organisation', :locals => { :admin_view => admin_view }
      end
    end

  end
end
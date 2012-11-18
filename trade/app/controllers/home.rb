require 'rubygems'
require 'require_relative'
require 'sinatra/base'
require 'haml'
require 'sinatra/content_for'
require_relative('../models/user')
require_relative('../models/item')
require_relative('../helpers/render')
require_relative '../helpers/before'

include Models
include Helpers

module Controllers
  class Home < Sinatra::Application
    before do
      before_for_user_not_authenticated
    end

    set :views , "#{absolute_path('../views', __FILE__)}"

    get '/' do
      redirect "/home" if session[:auth]
      session[:navigation].select(:unregistered)
      session[:navigation].get_selected.select(1)

      #get four random items
      item_list = Models::System.instance.fetch_all_active_items
      return_list = item_list.shuffle[0..3]
      haml :index, :locals => { :items_to_show => return_list }
    end

    get '/home' do
      redirect "/" unless session[:auth]

      if session[:user] == session[:account]
        session[:navigation].select(:user)
        session[:navigation].get_selected.select(1)
        haml :'home/user'
      else
        session[:navigation].select(:organisation)
        session[:navigation].get_selected.select(1)
        haml :'home/organisation'
      end
    end

    get '/home/user' do
      session[:navigation].select(:user)
      session[:navigation].get_selected.select_by_name("home")
      session[:navigation].get_selected.subnavigation.select_by_name("profile")

      haml :'home/user'
    end

    get '/home/organisation' do
      session[:navigation].select(:organisation)
      session[:navigation].get_selected.select_by_name("home")
      session[:navigation].get_selected.subnavigation.select_by_name("profile")

      haml :'home/organisation'
    end
  end
end
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
  class Sites < Sinatra::Application
    set :views , "#{absolute_path('../views', __FILE__)}"

    get '/logout' do
        haml :logout
    end

    get '/home' do
        haml :home
    end

    get '/home/active' do
        user = session[:user]
        haml :home_active, :locals => {:active_items => User.get_user(user).list_items}
    end

    get '/home/inactive' do
        user = session[:user]
        haml :home_inactive, :locals => {:inactive_items => User.get_user(user).list_items_inactive}
    end

    get '/home/new' do
        haml :home_new
    end

    get '/users' do
        viewer = session[:user]
        haml :users, :locals => {:all_users => User.get_all(viewer)}
    end

    get '/users/:id' do
        user = params[:id]
        haml :users_id, :locals => {:active_items => User.get_user(user).list_items}
    end

    get '/items' do
        viewer = session[:user]
        haml :items, :locals => {:all_items => Item.get_all(viewer)}
    end

    get '/error/:title' do
        msg = ""
        if params[:title] == "Not_A_Number"
          msg = "Price should be a number!"
        end
        if params[:title] == "Not_Enough_Credits"
          msg = "Sorry, but you can't buy this item, because you have not enough credits!"
        end
        haml :error, :locals => {:error_title => params[:title], :error_message => msg}
    end

  end
end
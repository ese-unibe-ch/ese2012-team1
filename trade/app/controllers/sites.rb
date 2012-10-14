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
        user_id = session[:user]
        haml :home_active, :locals => {:active_items => Models::System.instance.fetch_account(user_id).list_items}
    end

    get '/home/inactive' do
        user_id = session[:user]
        haml :home_inactive, :locals => {:inactive_items => Models::System.instance.fetch_account(user_id).list_items_inactive}
    end

    get '/home/new' do
        haml :home_new
    end

    get '/users' do
        viewer_id = session[:user]
        haml :users, :locals => {:all_users => Models::System.instance.fetch_all_accounts_but(viewer_id)}
    end

    get '/users/:id' do
        user_id = params[:id]
        haml :users_id, :locals => {:active_items => Models::System.instance.fetch_account(user_id.to_i).list_items_active}
    end

    get '/items' do
        viewer_id = session[:user]
        haml :items, :locals => {:all_items => Models::System.instance.fetch_all_active_items_but_of(viewer_id)}
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
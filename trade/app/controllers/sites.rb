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
        if session[:user] == session[:account]
          haml :home
        else
          haml :home_organisation
        end
    end

    get '/items/my/active' do
        redirect "/error/No_Valid_Account_Id" unless Models::System.instance.account_exists?(session[:account])
        user_id = session[:account]
        haml :items_my_active, :locals => {:active_items => Models::System.instance.fetch_account(user_id).list_items}
    end

    get '/items/my/inactive' do
        redirect "/error/No_Valid_Account_Id" unless Models::System.instance.account_exists?(session[:account])
        user_id = session[:account]
        haml :items_my_inactive, :locals => {:inactive_items => Models::System.instance.fetch_account(user_id).list_inactive_items}
    end

    get '/item/create' do
        haml :item_create
    end

    get '/users/all' do
        redirect "/error/No_Valid_Account_Id" unless Models::System.instance.account_exists?(session[:account])
        viewer_id = session[:account]
        haml :users_all, :locals => {:all_users => Models::System.instance.fetch_all_users_but(viewer_id)}
    end

    get '/users/:id' do
        redirect "/error/No_Valid_Account_Id" unless Models::System.instance.account_exists?(params[:id].to_i)
        user_id = params[:id]
        haml :users_id, :locals => {:active_items => Models::System.instance.fetch_account(user_id.to_i).list_active_items}
    end

    get '/items/active' do
        redirect "/error/No_Valid_Account_Id" unless Models::System.instance.account_exists?(session[:account])
        viewer_id = session[:account]
        haml :items_active, :locals => {:all_items => Models::System.instance.fetch_all_active_items_but_of(viewer_id)}
    end

    get '/error/:title' do
        msg = ""
        if params[:title] == "Not_A_Number"
          msg = "Price should be a number!"
        end
        if params[:title] == "Not_Enough_Credits"
          msg = "Sorry, but you can't buy this item, because you have not enough credits!"
        end
        if params[:title] == "No_Valid_Account_Id"
          msg = "Your account id could not be found"
        end
        if params[:title] == "No_Valid_User"
          msg = "Your email could not be found"
        end
        if params[:title] == "No_Name"
          msg = "Please enter a name"
        end
        if params[:title] == "No_Description"
          msg = "Please enter a description"
        end
        if params[:title] == "No_Valid_Item_Id"
          msg = "The requested item id could not be found"
        end
        if params[:title] == "Choose_Another_Name"
          msg = "The name you chose is already taken, choose another one"
        end
        haml :error, :locals => {:error_title => params[:title], :error_message => msg}
    end
  end
end
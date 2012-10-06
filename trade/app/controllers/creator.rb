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
  class Creator < Sinatra::Application
    set :views , "#{absolute_path('../views', __FILE__)}"

    before do
      redirect "/" unless session[:auth]
    end

    post '/create' do
        user = session[:user]
        begin
          new_item = User.get_user(user).create_item(params[:name], Integer(params[:price]))
          new_item.add_description(params[:description])
        rescue
          redirect "/error/Not_A_Number"
        end
        redirect "/home/inactive"
    end

    get '/changestate/:id/setactive' do
        id = params[:id]
        Item.get_item(id).to_active
        redirect "/home/inactive"
    end

    get '/changestate/:id/setinactive' do
        id = params[:id]
        Item.get_item(id).to_inactive
        redirect "/home/active"
    end

    post '/buy' do
        id = params[:id]
        item = Item.get_item(id)
        old_user = item.get_owner
        user = session[:user]
        new_user = User.get_user(user)
        if new_user.buy_new_item?(item)
          old_user.remove_item(item)
        else
          redirect "/error/Not_Enough_Credits"
        end
        redirect "/home/active"
    end

  end
end
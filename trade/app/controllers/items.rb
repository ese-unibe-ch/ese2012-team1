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
  class Items < Sinatra::Application
    set :views , "#{absolute_path('../views', __FILE__)}"

    before do
      redirect "/" unless session[:auth]
      response.headers['Cache-Control'] = 'public, max-age=0'
    end

    get '/items/my/active' do
        redirect "/error/No_Valid_Account_Id" unless Models::System.instance.account_exists?(session[:account])
        user_id = session[:account]
        haml :'item/my_active', :locals => {:active_items => Models::System.instance.fetch_account(user_id).list_items}
    end

    get '/items/my/inactive' do
        redirect "/error/No_Valid_Account_Id" unless Models::System.instance.account_exists?(session[:account])
        user_id = session[:account]
        haml :'item/my_inactive', :locals => {:inactive_items => Models::System.instance.fetch_account(user_id).list_inactive_items}
    end

    get '/item/create' do
        haml :'item/create'
    end

    get '/items/active' do
        redirect "/error/No_Valid_Account_Id" unless Models::System.instance.account_exists?(session[:account])
        viewer_id = session[:account]
        haml :'item/active', :locals => {:all_items => Models::System.instance.fetch_all_active_items_but_of(viewer_id)}
    end
  end
end
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
  class UserSites < Sinatra::Application
    set :views , "#{absolute_path('../views', __FILE__)}"

    before do
      redirect "/" unless session[:auth]
      response.headers['Cache-Control'] = 'public, max-age=0'
    end

    get '/users/all' do
        redirect "/error/No_Valid_Account_Id" unless Models::System.instance.account_exists?(session[:account])

        Navigations.get_selected.select_by_name("community")
        Navigations.get_selected.subnavigation.select_by_name("users")

        haml :'user/all', :locals => {:all_users => Models::System.instance.fetch_all_users_but(session[:account])}
    end

    get '/users/:id' do
        redirect "/error/No_Valid_Account_Id" unless Models::System.instance.account_exists?(params[:id].to_i)
        user_id = params[:id]
        haml :'user/id', :locals => {:active_items => Models::System.instance.fetch_account(user_id.to_i).list_active_items}
    end

  end
end
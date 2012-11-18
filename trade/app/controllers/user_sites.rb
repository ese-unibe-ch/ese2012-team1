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
  class UserSites < Sinatra::Application
    before do
      before_for_user_authenticated
    end

    set :views , "#{absolute_path('../views', __FILE__)}"

    get '/users/all' do
        redirect "/error/No_Valid_Account_Id" unless Models::System.instance.account_exists?(session[:account])

        session[:navigation].get_selected.select_by_name("community")
        session[:navigation].get_selected.subnavigation.select_by_name("users")

        haml :'user/all', :locals => {:all_users => Models::System.instance.fetch_all_users_but(session[:account])}
    end

    get '/users/:id' do
        redirect "/error/No_Valid_Account_Id" unless Models::System.instance.account_exists?(params[:id].to_i)
        user_id = params[:id]
        haml :'user/id', :locals => {:active_items => Models::System.instance.fetch_account(user_id.to_i).list_active_items}
    end

  end
end
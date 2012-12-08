require 'rubygems'
require 'require_relative'
require 'sinatra/base'
require 'haml'
require 'sinatra/content_for'
require_relative('../models/user')
require_relative('../models/item')
require_relative('../helpers/render')
require_relative '../helpers/before'

require 'json'

include Models
include Helpers

module Controllers
  class UserSites < Sinatra::Application
    before do
      before_for_user_authenticated
    end

    set :views , "#{absolute_path('../views', __FILE__)}"

    get '/messagebox/send' do
      haml :'/user/mailbox/send', :locals => { :script => "search_users.js" }
    end

    post '/messagebox/send' do
      message = "<h1>You have send:</h1> <br><br>"

      message += "To: "
      params.each do |key, user_id|
        message += user_id + ", " if (key.include?("hidden"))
      end

      message += "<br>"
      message += "Subject: " + params[:subject] + "<br>"
      message += "Message: " + params[:message] + "<br>"

      message
    end

    get '/users' do
      content_type :json

      users = Models::System.instance.fetch_all_users_but(session[:account])
      users.delete_if do |user|
        !user.name.include?(params[:query])
      end

      data = users.map { |user| user.id }
      suggestion = users.map { |user| user.name }

      users = {
          "query" => params[:query],
          "suggestions" => suggestion,
          "data" => data
      }

      users.to_json
    end

    get '/users/all' do
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
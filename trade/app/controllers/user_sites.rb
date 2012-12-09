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

##
#
# Here all sites that display one or multiple users(independent
# from their organisations) are handled
#
##
module Controllers
  class UserSites < Sinatra::Application
    before do
      before_for_user_authenticated
    end

    set :views , "#{absolute_path('../views', __FILE__)}"

    ##
    #
    # Shows a list of all users in the system
    #
    # Redirects:
    # /error/No_Valid_Account_Id when the user id couldn't be found
    #
    # Expected:
    # session[:account] id of the user who wants to see all users
    # session[:navigation] has to be initialized
    #
    ##
    get '/users/all' do
        session[:navigation].get_selected.select_by_name("community")
        session[:navigation].get_selected.subnavigation.select_by_name("users")

        haml :'user/all', :locals => {:all_users => Models::System.instance.fetch_all_users_but(session[:account])}
    end

    ##
    #
    # Shows the profile of a specific user
    #
    # Redirects:
    # /error/No_Valid_Account_Id when the user you want to see doesn't exist
    #
    # Expected:
    # session[:account] : id of the user who wants to see a users
    # params[:id] : the user you want to see
    #
    ##
    get '/users/:id' do
        redirect "/error/No_Valid_Account_Id" unless Models::System.instance.account_exists?(params[:id].to_i)
        user_id = params[:id]
        haml :'user/id', :locals => {:active_items => Models::System.instance.fetch_account(user_id.to_i).list_active_items}
    end

    ##
    #
    # Shows the form to send a message to another user
    #
    ##
    get '/messagebox/send' do
      haml :'/user/mailbox/send', :locals => { :receiver_id => params[:receiver_id],
                                               :receiver_name => params[:receiver_name], }
    end

    ##
    #
    # Sends the message
    #
    # Expects:
    # params[:subject] : the subject of the message
    # param[:message] : the actual text message
    #
    ##
    post '/messagebox/send' do
      @error[:message] = "You have to enter a message" if params[:message].nil? || params[:message].empty?

      unless @error.empty?
        halt       haml :'/user/mailbox/send', :locals => { :receiver_id => params[:receiver_id],
                                                            :receiver_name => params[:receiver_name], }
      end

      message = "<h1>You have send:</h1> <br><br>"

      message += "To: "

      receivers = Array.new
      params.each do |key, user_id|
        receivers.push(user_id) if (key.include?("hidden"))
      end

      if (receivers.size == 0)
        session[:alert] = Alert.create("", "You have not entered any receivers", true)
        redirect '/messagebox/send'
      end

      message +=  receivers.join(",")

      message += "<br>"
      message += "Subject: " + params[:subject] + "<br>"
      message += "Message: " + params[:message] + "<br>"

      message
    end

    ##
    #
    # TODO: add description
    #
    ##
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

  end
end
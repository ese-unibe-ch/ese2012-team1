require 'rubygems'
require 'require_relative'
require 'sinatra/base'
require 'haml'
require 'sinatra/content_for'
require_relative '../models/user'
require_relative('../helpers/render')

include Models
include Helpers

module Controllers
  class Authentication < Sinatra::Application
    set :views , "#{absolute_path('../views', __FILE__)}"

    get '/' do
      redirect "/home" if session[:auth]

      #get four random items
      item_list = Models::System.instance.fetch_all_active_items
      return_list = item_list.shuffle[0..3]
      haml :index, :locals => { :items_to_show => return_list }
    end

    get '/login' do
      redirect "/home" if session[:auth]

      haml :'authentication/login', :locals => { :onload => 'document.loginform.username.focus()' }
    end

    post "/authenticate" do
      #Nicht sauber!

      if (!Models::System.instance.user_exists?(params[:username]))
        haml :'authentication/login', :locals => { :error_message => 'No such user or password!'}
      else
        user = Models::System.instance.fetch_user_by_email(params[:username])
        if !user.login(params[:password])
          haml :'authentication/login', :locals => { :error_message => 'No such user or password!'}
        else
          session[:user] = user.id
          session[:account] = user.id
          session[:auth] = true
          redirect "/home"
        end
      end
    end

    post "/unauthenticate" do
      session[:user] = nil
      session[:auth] = false
      session.clear
      redirect "/"
    end

    get "/unauthenticate" do
      session[:user] = nil
      session[:auth] = false
      redirect "/"
    end
  end
end
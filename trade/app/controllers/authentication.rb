require 'rubygems'
require 'require_relative'
require 'sinatra/base'
require 'haml'
require 'sinatra/content_for'
require_relative '../models/user'
require_relative '../helpers/alert'
require_relative('../helpers/render')
require_relative '../helpers/before'

include Models
include Helpers

module Controllers
  class Authentication < Sinatra::Application
    before do
      before_for_user_not_authenticated
    end

    set :views , "#{absolute_path('../views', __FILE__)}"

    get '/login' do
      redirect '/home' if session[:auth]

      session[:navigation].select(:unregistered)
      session[:navigation].get_selected.select_by_name("login")
      haml :'authentication/login', :locals => { :onload => 'document.loginform.username.focus()' }
    end

    get '/logout' do
      redirect "/" unless session[:auth]
      haml :'authentication/logout'
    end

    post "/authenticate" do
      if (!Models::System.instance.user_exists?(params[:username]))
        session[:alert] = Alert.create("", "No such user or password", true)
        redirect '/login'
      else
        user = Models::System.instance.fetch_user_by_email(params[:username])
        if !user.login(params[:password])
          session[:alert] = Alert.create("", "No such user or password", true)
          redirect '/login'
        else
          if !user.activated
            session[:alert] = Alert.create("", "You haven't activated you're account yet. Please check your mailbox", true)
            redirect '/login'
          else
            session[:user] = user.id
            session[:account] = user.id
            session[:auth] = true
            redirect "/home"
          end
        end
      end
    end

    post "/unauthenticate" do
      session[:user] = nil
      session[:auth] = false
      session.clear

      session[:alert] = Alert.create("", "You succesfully logged out. Have a nice day!", false)
      redirect "/"
    end
  end
end
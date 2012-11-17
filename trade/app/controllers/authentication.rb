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

    before do
      response.headers['Cache-Control'] = 'public, max-age=0'
    end

    get '/login' do
      redirect "/home" if session[:auth]

      session[:navigation_selected] = 2
      haml :'authentication/login', :locals => { :onload => 'document.loginform.username.focus()' }
    end

    get '/logout' do
      redirect "/" unless session[:auth]
      haml :'authentication/logout'
    end

    post "/authenticate" do
      #Nicht sauber!

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
      redirect "/"
    end
  end
end
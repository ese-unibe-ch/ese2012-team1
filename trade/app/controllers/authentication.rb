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

    get '/login' do
      redirect "/home" if session[:auth]

      haml :'authentication/login', :locals => { :onload => 'document.loginform.username.focus()' }
    end

    post "/authenticate" do
      #Nicht sauber!
      user = Models::System.instance.fetch_user_by_email(params[:username])
      if user.login(params[:password])
        session[:user] = user.id
        session[:account] = user.id
        session[:auth] = true
        redirect "/home"
      else
        haml :'authentication/login', :locals => { :error_message => 'No such user or password!'}
      end
    end

    post '/unauthenticate' do
      session[:user] = nil
      session[:auth] = false
      session.clear
      redirect "/"
    end

    get '/logout' do
      redirect "/" unless session[:auth]
      response.headers['Cache-Control'] = 'public, max-age=0'
      haml :'authentication/logout'
    end
  end
end
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

      haml :index
    end

    get '/login' do
      redirect "/home" if session[:auth]

      haml :login, :locals => { :onload => 'document.loginform.username.focus()' }
    end

    post "/authenticate" do
      user = Models::System.instance.fetch_user_by_email(params[:username])
      if User.login(user, params[:password])
        session[:user] = user.id
        session[:auth] = true
        redirect "/home"
      else
        haml :login, :locals => { :error_message => 'No such user or password!'}
      end
    end

    post "/unauthenticate" do
      session[:user] = nil
      session[:auth] = false
      redirect "/"
    end

    get "/unauthenticate" do
      session[:user] = nil
      session[:auth] = false
      redirect "/"
    end
  end
end
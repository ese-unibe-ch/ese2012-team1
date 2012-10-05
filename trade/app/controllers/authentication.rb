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

      haml :login
    end

    post "/authenticate" do
      halt 401, "No such login" unless User.login params[:username], params[:password]

      session[:user] = params[:username]
      session[:auth] = true

      redirect "/home"
    end

    post "/unauthenticate" do
      session[:user] = nil
      session[:auth] = false
      redirect "/"
    end

    get '/register' do
      haml :register, :locals => { :script => 'passwordchecker.js', :onload => 'initialize()' }
    end

    post '/register' do
      "You are to be registered..."
      User.created(params[:name], params[:password])
      "You are to be registered..."
    end
  end
end
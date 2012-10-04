def relative(path)
  File.join(File.expand_path(File.dirname(__FILE__)), path)
end
require 'rubygems'
require 'require_relative'
require 'sinatra/base'
require 'haml'
require 'sinatra/content_for'
require_relative '../models/user'

include Models

module Controllers
  class Authentication < Sinatra::Application

    set :views, relative('../../app/views')
    helpers Sinatra::ContentFor

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

  end
end
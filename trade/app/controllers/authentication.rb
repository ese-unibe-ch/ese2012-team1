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

    # AK this seems to be an odd place to put it.
    get '/' do
      redirect "/home" if session[:auth]

      #get four random items
      item_list = Models::System.instance.fetch_all_active_items
      counter = item_list.size # AK: return_list = item_list.shuffle[0..3]
      return_list = Array.new  # there should be no noticable performance impact
      range = 0..3             # It also ensures that any item is at most once in the
      for zahl in range do     # list.
        return_list.push(item_list[rand(counter)])
      end
      haml :index, :locals => { :items_to_show => return_list }
    end

    get '/login' do
      redirect "/home" if session[:auth]

      haml :login, :locals => { :onload => 'document.loginform.username.focus()' }
    end

    post "/authenticate" do
      #Nicht sauber!
      user = Models::System.instance.fetch_user_by_email(params[:username])
      if User.login(user, params[:password])
        session[:user] = user.id
        session[:account] = user.id
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

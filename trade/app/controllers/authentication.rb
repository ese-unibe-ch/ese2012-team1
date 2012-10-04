def relative(path)
  File.join(File.expand_path(File.dirname(__FILE__)), path)
end
require 'rubygems'
require 'require_relative'
require 'sinatra/base'
require 'haml'
require 'sinatra/content_for'
require_relative('../models/module/user')
require_relative('../helpers/render')

include Models
include Helpers

module Controllers
  class Authentication < Sinatra::Base

    set :views, relative('../../app/views')
    helpers Sinatra::ContentFor

    get '/' do
      session['auth']

      if session['auth']
        redirect "/home"
      else
        haml :index
      end
    end

    get '/login' do
      if session['auth']
        redirect "/home"
      else
        haml :login
      end
    end

    post "/authenticate" do
      halt 401, "No such login" unless User.login params[:username], params[:password]

      session['user'] = params[:username]
      session['auth'] = true

      redirect "/home"
    end

    post "/unauthenticate" do
      session['user'] = nil
      session['auth'] = false
      redirect "/"
    end

  end
end
require 'rubygems'
require 'require_relative'
require 'sinatra/base'
require 'haml'
require 'sinatra/content_for'
require_relative('../models/user')
require_relative('../models/item')
require_relative('../helpers/render')

include Models
include Helpers

module Controllers
  class Switch < Sinatra::Application
    set :views , "#{absolute_path('../views', __FILE__)}"

    post '/organisationswitch' do
      value = params[:organisation]
      user = session[:user]
      if Models::System.instance.fetch_account(user).email == value
        session[:organisation] = "none"
        session[:account] = Models::System.instance.fetch_account(user).id
      else
        session[:organisation] = value
        session[:account] = Models::System.instance.fetch_organisation_by_name(value).id
      end
      redirect '/home'
    end


  end
end
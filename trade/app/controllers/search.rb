require 'rubygems'
require 'require_relative'
require 'sinatra/base'
require 'haml'
require 'sinatra/content_for'
require_relative('../models/user')
require_relative('../models/item')
require_relative('../helpers/render')
require_relative '../helpers/before'
require_relative('../helpers/string_checkers')

include Models
include Helpers

module Controllers
  class Search < Sinatra::Application

      set :views, "#{absolute_path('../views', __FILE__)}"

      before do
        before_for_user_authenticated
      end

      get "/search.?" do

        results = System.instance.search.find(params[:pattern])

        haml :search, :locals => { :results => results }
      end
  end
end
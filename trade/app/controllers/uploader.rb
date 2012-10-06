require 'rubygems'
require 'require_relative'
require 'sinatra/base'
require 'haml'
require 'ftools'
require_relative('../models/user')
require_relative('../helpers/render')

include Models
include Helpers

module Controllers
  class Uploader < Sinatra::Base

    set :views , "#{absolute_path('../views', __FILE__)}"

    get '/ul' do
      haml :ultest
    end

    post '/upload/users' do
      dir = absolute_path('../public/images/users/', __FILE__)
      tempfile = params['myfile'][:tempfile]
      filename = params['myfile'][:filename]
      File.copy(tempfile.path, "#{dir}#{filename}")
      redirect back
    end

    post '/upload/items' do
      dir = absolute_path('../public/images/items/', __FILE__)
      tempfile = params['myfile'][:tempfile]
      filename = params['myfile'][:filename]
      File.copy(tempfile.path, "#{dir}#{filename}")
      redirect back
    end

  end
end
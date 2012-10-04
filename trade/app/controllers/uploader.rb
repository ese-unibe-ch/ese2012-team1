def relative(path)
  File.join(File.expand_path(File.dirname(__FILE__)), path)
end
require 'rubygems'
require 'require_relative'
require 'sinatra/base'
require 'haml'
require 'ftools'
require 'sinatra/content_for'
require_relative('../models/module/user')
require_relative('../helpers/render')

include Models
include Helpers

module Controllers
  class Uploader < Sinatra::Base

    set :views, relative('../../app/views')
    helpers Sinatra::ContentFor

    get '/ul' do
      haml :ultest
    end

    post '/upload/users' do
      dir = relative('public/images/users/')
      tempfile = params['myfile'][:tempfile]
      filename = params['myfile'][:filename]
      File.copy(tempfile.path, "#{dir}#{filename}")
      redirect back
    end

    post '/upload/items' do
      dir = relative('public/images/items/')
      tempfile = params['myfile'][:tempfile]
      filename = params['myfile'][:filename]
      File.copy(tempfile.path, "#{dir}#{filename}")
      redirect back
    end

  end
end
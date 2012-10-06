require 'rubygems'
require 'require_relative'
require 'sinatra/base'
require 'haml'
require 'ftools'
require_relative '../models/user'
require_relative '../helpers/render'

include Models
include Helpers

module Controllers
  class Registration < Sinatra::Application
    set :views , "#{absolute_path('../views', __FILE__)}"

    ##
    #
    # Loads register.haml and includes passwordchecker.js to do
    # realtime checking of the password typed in.
    #
    ##

    get '/register' do
      haml :register, :locals => { :script => 'passwordchecker.js', :onload => 'initialize()' }
    end

    ##
    #
    # Gets registration data from user. Redirected from register.haml with
    # Form. Checks if incoming data is correct and redirects to login. If
    # data is correct redirect to '/register'.
    #
    # Should get parameter
    # :name - User name
    # :password - User password
    #
    ##

    post '/register' do
      if params[:password].length < 6 || params[:password] =~ /[^a-zA-Z1-9]/ ||
         params[:password] != params[:re_password] ||
         params[:email].nil? || params[:name].nil? #Still missing conditions...

        redirect '/register'
      end

      password = params[:password]
      email = params[:email]
      description = params[:description].nil? ? "" : params[:description]
      name = params[:name]


      dir = absolute_path('../public/images/users/', __FILE__)
      file_path = "../images/users/default_avatar.png"

      if params[:avatar] != nil
        tempfile = params[:avatar][:tempfile]
        filename = params[:avatar][:filename]
        file_path ="#{dir}#{params[:name]}.#{filename.sub(/.*\./, "")  }"
        File.copy(tempfile.path, file_path)
        file_path = "../images/users/#{params[:name]}.#{filename.sub(/.*\./, "")}"
      end

      User.created(name, password, email, description, file_path)

      redirect '/login'
    end

    ##
    #
    # Removes a user from the system and redirects
    # to '/unauthenticate'
    #
    ##

    post '/unregister' do
      user = User.get_user(session[:user])
      user.clear

      redirect '/unauthenticate'
    end
  end
end
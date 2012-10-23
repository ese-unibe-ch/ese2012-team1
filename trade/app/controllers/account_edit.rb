require 'rubygems'
require 'require_relative'
require 'sinatra/base'
require 'haml'
require 'ftools'

require_relative '../models/user'
require_relative '../helpers/render'
require_relative '../helpers/string_checkers'
require_relative '../models/simple_email_client' unless ENV['RACK_ENV'] == 'test'

include Models
include Helpers

module Controllers
  class AccountEdit < Sinatra::Application
    set :views, "#{absolute_path('../views', __FILE__)}"

    ##
    # Loads edit_profile.haml and includes passwordchecker.js to do
    # realtime checking of the password typed in.
    ##

    get '/account/edit/user/profile' do
      haml :'user/edit_profile', :locals => {:script => 'passwordchecker.js', :onload => 'initialize()'}
    end

    ##
    #
    # Gets edited profile data from user. Redirected from edit_profile.haml with
    # Form. Checks if incoming data is correct and redirects to home.
    #
    # Should get parameter
    # :password - User password
    # :email - User e-mail
    # optional :description - A description of the user
    # optional :avatar - A file for the avatar
    #
    ##

    post '/account/edit/user/profile' do
      user = Models::System.instance.fetch_account(session[:user])
      session[:email_error] = nil
      #Error Messages Sessions
      if (params[:email] != nil)
        newMailUser = Models::System.instance.fetch_user_by_email(params[:email])
        if (newMailUser != nil)
          session[:email_error] = "You entered a e-mail which is already in use." if (newMailUser != user)
          session[:is_email_error] = "yes" if (newMailUser != user)
        end
        session[:email_error] = "You entered a incorrect e-mail address" if params[:email] == "" || !params[:email].is_email?
        session[:is_email_error] = "yes" if params[:email] == "" || !params[:email].is_email?
      end

      if (!session[:email_error].nil?)
        redirect '/account/edit/user/profile'
      end


      session[:is_email_error] = ""

      if (!params[:password].nil?)
        user.password(params[:password])
      end
      if (!params[:email].nil?)
        user.email = params[:email]
      end
      if (!params[:interests].nil?)
        user.description = params[:interests].nil? ? "" : params[:interests]
      end

      dir = absolute_path('../public/images/users/', __FILE__)
      file_path = "/images/users/default_avatar.png"

      if params[:avatar] != nil
        tempfile = params[:avatar][:tempfile]
        filename = params[:avatar][:filename]
        file_path ="#{dir}"+user.name+".#{filename.sub(/.*\./, "")  }"
        File.copy(tempfile.path, file_path)
        file_path = "/images/users/"+user.name+".#{filename.sub(/.*\./, "")}"
        user.avatar = file_path
      end

      redirect '/'
    end

    ##
    # Loads edit.haml where user can enter the new informations
    ##

    get '/account/edit/organisation/profile' do
      haml :'organisation/edit'
    end

    ##
    #
    # Gets edited profile data from user. Redirected from edit.haml.haml with
    # Form. Checks if incoming data is correct and redirects to home.
    #
    # Should get parameter
    # optional :description - A description of the user
    # optional :avatar - A file for the avatar
    #
    ##

    post '/account/edit/organisation/profile' do
      organisation = Models::System.instance.fetch_account(session[:account])


      if (!params[:description].nil?)
        organisation.description = params[:description].nil? ? "" : params[:description]
      end

      dir = absolute_path('../public/images/organisations/', __FILE__)
      file_path = "/images/organisations/default_avatar.png"

      if params[:avatar] != nil
        tempfile = params[:avatar][:tempfile]
        filename = params[:avatar][:filename]
        file_path ="#{dir}"+organisation.name+".#{filename.sub(/.*\./, "")  }"
        File.copy(tempfile.path, file_path)
        file_path = "/images/organisations/"+organisation.name+".#{filename.sub(/.*\./, "")}"
        organisation.avatar = file_path
      end

      redirect '/'
    end


  end
end
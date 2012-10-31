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
  class Registration < Sinatra::Application
    set :views , "#{absolute_path('../views', __FILE__)}"

    before do
      response.headers['Cache-Control'] = 'public, max-age=0'
    end

    ##
    # activates a user
    ##
    get '/registration/confirm/:user' do
      if Models::System.instance.user_exists?(params[:user])
        #mail = BCrypt::Password.new(params[:user])
        mail=params[:user]

        user = Models::System.instance.fetch_user_by_email(mail)
        user.activate
      end

      redirect "/"
    end


    ##
    #
    # Loads register.haml and includes passwordchecker.js to do
    # realtime checking of the password typed in.
    #
    ##

    get '/register' do
      haml :'authentication/register', :locals => { :script => 'passwordchecker.js', :onload => 'initialize()' }
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
    # :email - User e-mail
    # optional :description - A description of the user
    # optional :avatar - A file for the avatar
    #
    ##

    ##
    #
    # Checks if one of the given arguments is a member
    # of the Nil class.
    #
    ##

    def are_nil?(*args)
      result = false
      args.each do |arg|
        result = result || arg == nil
      end
      result
    end

    post '/register' do
      if are_nil?(params[:password], params[:re_password], params[:email], params[:name]) ||
         ! params[:password].is_strong_password? || params[:password] != params[:re_password] ||
          params[:email] == "" || ! params[:email].is_email? || params[:name] == "" || Models::System.instance.user_exists?(params[:email])

        #Error Messages Sessions
        session[:email_error] = ""
        session[:email_error] = "E-Mail Address already in use." if Models::System.instance.user_exists?(params[:email])
        session[:email_error] = "Not a correct E-Mail Address" if params[:email] == "" || !params[:email].is_email?
        session[:is_email_error] = "yes" if Models::System.instance.user_exists?(params[:email])
        session[:is_email_error] = "yes" if params[:email] == "" || !params[:email].is_email?

        #Values from wrong form data
        session[:form_email] = params[:email]
        session[:form_name] = params[:name]
        session[:form_description] = params[:interests]

        redirect '/register'
      end

      session[:email_error] = ""
      session[:is_email_error] = ""
      session[:form_email] = ""
      session[:form_name] = ""
      session[:form_description] = ""

      password = params[:password]
      email = params[:email]
      description = params[:interests].nil? ? "" : params[:interests]
      name = params[:name]

      dir = absolute_path('../public/images/users/', __FILE__)
      file_path = "/images/users/default_avatar.png"

      if params[:avatar] != nil
        tempfile = params[:avatar][:tempfile]
        filename = params[:avatar][:filename]
        file_path ="#{dir}#{params[:name]}.#{filename.sub(/.*\./, "")  }"
        File.copy(tempfile.path, file_path)
        file_path = "/images/users/#{params[:name]}.#{filename.sub(/.*\./, "")}"
      end

      user = User.created(name, password, email, description, file_path)
      #session[:user] = user.id
      #session[:auth] = true
      #session[:account] = user.id
      
      Mailer.setup.sendRegMail(user.id, "#{request.host}:#{request.port}")
      #SimpleEmailClient.setup.send_email(email, "Welcome to the ESE-Tradingsystem!", "You are now registered in the ESE-Tradingsystem.\nBefore you can use your account activate it by clicking here: http://localhost:4567/account/edit/user/activate/#{email}\nHave fun!")

      redirect '/'
    end

    ##
    #
    # Removes an user from the system and redirects
    # to '/unauthenticate'
    #
    ##
    get '/unregister' do
      redirect "/" unless session[:auth]
      haml :'authentication/unregister'
    end


    post '/unregister' do
      redirect "/" unless session[:auth]
      redirect "/error/No_Valid_Account_Id" unless Models::System.instance.account_exists?(session[:user])
      user = Models::System.instance.fetch_account(session[:user])
      user.clear
      session.clear

      redirect '/unauthenticate'
    end
  end
end
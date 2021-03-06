include Models
include Helpers

##
# In this controller the login and logout process
# is handled.
##

module Controllers
  class Authentication < Sinatra::Application
    set :views , "#{absolute_path('../views', __FILE__)}"

    ###
    #
    #  Used to get on the login screen.
    #
    #  Redirects to:
    #  /home when the user is already logged in
    #
    #  Expects:
    #  session[:auth] : true or false
    #  session[:navigation] : has to be initialized
    #
    ###

    get '/login' do
      before_for_user_not_authenticated

      redirect '/home' if session[:auth]

      session[:navigation][:context] = :unregistered
      session[:navigation][:selected] = "login"
      haml :'authentication/login', :locals => { :onload => 'document.loginform.username.focus()' }
    end

    ###
    #
    #  Used to request a logout
    #
    #  Redirects to:
    #  / when the user is not logged in
    #
    ###

    get '/logout' do
      before_for_user_not_authenticated

      redirect "/" unless session[:auth]
      haml :'authentication/logout'
    end

    ###
    #
    #  After this a user is logged in and will see his home screen
    #
    #  Redirects to:
    #  /login when the user does not exist, his password is wrong or he is not activated
    #  /home when everything is okay
    #
    ###
    post "/authenticate" do
      before_for_user_not_authenticated

      error_redirect("", "No such user or password", !DAOAccount.instance.email_exists?(params[:username]), "/login")
      user = DAOAccount.instance.fetch_user_by_email(params[:username])
      error_redirect("", "No such user or password", !user.login(params[:password]), "/login")
      error_redirect("", "You haven't activated you're account yet. Please check your mailbox", !user.activated, "/login")

      session[:user] = user.id
      session[:account] = user.id
      session[:auth] = true
      redirect "/home"

    end

    ###
    #
    #  After this a user is logged out and will see the start page.
    #  It also resets all session params.
    #
    #  Redirects to:
    #  / always
    #
    ###
    post "/unauthenticate" do
      before_for_user_not_authenticated

      session[:user] = nil
      session[:auth] = false
      session.clear

      session[:alert] = Alert.create("", "You successfully logged out. Have a nice day!", false)
      redirect "/"
    end
  end
end
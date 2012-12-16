include Models
include Helpers

##
#
# Here all sites that display one or multiple users(independent
# from their organisations) are handled
#
##
module Controllers
  class UserSites < Sinatra::Application
    before do
      before_for_user_authenticated
    end

    set :views , "#{absolute_path('../views', __FILE__)}"

    ##
    #
    # Shows a list of all users in the system
    #
    # Redirects:
    # /error/No_Valid_Account_Id when the user id couldn't be found
    #
    # Expected:
    # session[:account] id of the user who wants to see all users
    # session[:navigation] has to be initialized
    #
    ##
    get '/users/all' do
        session[:navigation][:selected]  = "community"
        session[:navigation][:subnavigation] = "users"

        haml :'user/all', :locals => {:all_users => DAOAccount.instance.fetch_all_users_but(session[:account])}
    end

    ##
    #
    # Shows the profile of a specific user
    #
    # Redirects:
    # /error/No_Valid_Account_Id when the user you want to see doesn't exist
    #
    # Expected:
    # session[:account] : id of the user who wants to see a users
    # params[:id] : the user you want to see
    #
    ##
    get '/users/:id' do
        error_redirect("Oh no!", "There's something gone wrong.", !DAOAccount.instance.account_exists?(params[:id].to_i), "/home")
        user_id = params[:id]
        redirect "/home" if user_id.to_s == session[:account].to_s
        haml :'user/id', :locals => {:active_items => DAOAccount.instance.fetch_account(user_id.to_i).list_active_items}
    end
  end
end
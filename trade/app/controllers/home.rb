include Models
include Helpers

##
# Here are requests concerning the start screen for unauthenticated users
# and for viewing profiles handled.
##
module Controllers
  class Home < Sinatra::Application

    set :views , "#{absolute_path('../views', __FILE__)}"

    before_when_route_is_taken do
      before_for_user_not_authenticated
    end

    ###
    #
    #  Shows unauthenticated users a list of random items in the system
    #
    #  Redirects to:
    #  /home when the user is authenticated
    #
    #  Expects:
    #  session[:auth] : true or false
    #  session[:navigation] : has to be initialized
    #
    ###
    get '/' do
      redirect "/home" if session[:auth]

      session[:navigation][:context] = :unregistered
      session[:navigation][:selected] = "home"

      #get four random items
      item_list = DAOItem.instance.fetch_all_active_items
      return_list = item_list.shuffle[0..3]
      haml :index, :locals => { :items_to_show => return_list }
    end

    ###
    #
    #  Shows authenticated users or organisations their profile information
    #  Differences slightly between admins and non-admins of a org. in what they
    #  can do on this page.
    #
    #  Redirects to:
    #  / when the user is not authenticated
    #
    #  Expects:
    #  session[:user] : the user id
    #  session[:navigation] : has to be initialized
    #  session[:account] : the account id on which behalf this user is acting now
    #  session[:auth] : true or false
    #
    ###
    get '/home' do
      redirect "/" unless session[:auth]

      if session[:user] == session[:account]
        session[:navigation][:context] = :user
        session[:navigation][:selected] = "home"
        session[:navigation][:subnavigation] = "profile"

        haml :'home/user'
      else
		    admin_view = DAOAccount.instance.fetch_account(session[:account]).is_admin?(DAOAccount.instance.fetch_account(session[:user]))
        if admin_view
          session[:navigation][:context] = :organisation_admin
        else
          session[:navigation][:context] = :organisation
        end
        session[:navigation][:selected]  = "home"
        session[:navigation][:subnavigation] = "profile"

        haml :'home/organisation', :locals => { :admin_view => admin_view }
      end
    end

    ###
    #
    #  TODO: Is this even used?
    #
    ###
    get '/home/user' do
      session[:navigation][:context] = :user
      session[:navigation][:selected] = "home"
      session[:navigation][:subnavigation] = "profile"

      haml :'home/user'
    end

    ###
    #
    #  TODO: Is this even used?
    #
    ###
    get '/home/organisation' do
      session[:navigation][:context] = :organisation
      session[:navigation][:selected] = "home"
      session[:navigation][:subnavigation] = "profile"

      admin_view = DAOAccount.instance.fetch_account(session[:account]).is_admin?(DAOAccount.instance.fetch_account(session[:user]))

      haml :'home/organisation', :locals => { :admin_view => admin_view }
    end
  end
end
include Models
include Helpers

##
# Here are requests concerning the start screen for unauthenticated users
# and for viewing profiles handled.
##
module Controllers
  class Home < Sinatra::Application

    set :views , "#{absolute_path('../views', __FILE__)}"

    before do
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

      session[:navigation].select(:unregistered)
      session[:navigation].get_selected.select(1)

      #get four random items
      item_list = Models::System.instance.fetch_all_active_items
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
        session[:navigation].select(:user)
        session[:navigation].get_selected.select_by_name("home")
        session[:navigation].get_selected.subnavigation.select_by_name("profile")

        haml :'home/user'
      else
		    admin_view = Models::System.instance.fetch_account(session[:account]).is_admin?(Models::System.instance.fetch_account(session[:user]))
        if admin_view
          session[:navigation].select(:organisation_admin)
        else
          session[:navigation].select(:organisation)
        end
        session[:navigation].get_selected.select_by_name("home")
        session[:navigation].get_selected.subnavigation.select_by_name("profile")

        haml :'home/organisation', :locals => { :admin_view => admin_view }
      end
    end

    ###
    #
    #  TODO: Is this even used?
    #
    ###
    get '/home/user' do
      session[:navigation].select(:user)
      session[:navigation].get_selected.select_by_name("home")
      session[:navigation].get_selected.subnavigation.select_by_name("profile")

      haml :'home/user'
    end

    ###
    #
    #  TODO: Is this even used?
    #
    ###
    get '/home/organisation' do
      session[:navigation].select(:organisation)
      session[:navigation].get_selected.select_by_name("home")
      session[:navigation].get_selected.subnavigation.select_by_name("profile")

      admin_view = Models::System.instance.fetch_account(session[:account]).is_admin?(Models::System.instance.fetch_account(session[:user]))

      haml :'home/organisation', :locals => { :admin_view => admin_view }
    end
  end
end
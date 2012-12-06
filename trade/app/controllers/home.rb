include Models
include Helpers

module Controllers
  class Home < Sinatra::Application

    set :views , "#{absolute_path('../views', __FILE__)}"

    get '/' do
      before_for_user_not_authenticated

      redirect "/home" if session[:auth]

      session[:navigation].select(:unregistered)
      session[:navigation].get_selected.select(1)

      #get four random items
      item_list = Models::System.instance.fetch_all_active_items
      return_list = item_list.shuffle[0..3]
      haml :index, :locals => { :items_to_show => return_list }
    end

    get '/home' do
      before_for_user_not_authenticated

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
  end
end
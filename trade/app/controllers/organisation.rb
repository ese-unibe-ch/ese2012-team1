include Models
include Helpers


##
#
# In this controller all actions and view-requests concerning
# an organisation are handled
#
##
module Controllers
  class Organisation < Sinatra::Application
  set :views, "#{absolute_path('../views', __FILE__)}"

    before do
      before_for_user_authenticated
    end

    ###
    #
    # Shows form to create an organisation by user
    #
    ##

    get '/organisation/create' do
      session[:navigation][:selected] = "home"
      session[:navigation][:subnavigation] = "organisation"

      haml :'organisation/create'
    end

    ##
    #
    #  Creates an organisation.
    #  Called from organisation/create.haml
    #
    #  Expects:
    #  params[:name] : Name of the organisation
    #  params[:description] : Description to organisation
    #  params[:limit] : Limit for normal users to spend
    #
    #  optional params[:avatar] : Picture for organisation
    #
    ##

    post '/organisation/create' do
      @error[:name] = ErrorMessages.get("No_Name") if params[:name].nil? || params[:name].length == 0
      @error[:name] = ErrorMessages.get("Choose_Another_Name") if DAOAccount.instance.organisation_exists?(params[:name])
      @error[:limit] = ErrorMessages.get("Wrong_Limit") if params[:limit] != "" && !(/^[\d]+(\.[\d]+){0,1}$/.match(params[:limit]))

      unless @error.empty?
        halt haml :'/organisation/create'
      end

      params[:description] = "" if params[:description].nil?

      dir = absolute_path('../public/images/organisations/', __FILE__)
      file_path = "/images/organisations/default_avatar.png"

      if params[:avatar] != nil
        tempfile = params[:avatar][:tempfile]
        filename = params[:avatar][:filename]
        file_path ="#{dir}#{params[:name]}.#{filename.sub(/.*\./, "")  }"
        File.copy(tempfile.path, file_path)
        file_path = "/images/organisations/#{params[:name]}.#{filename.sub(/.*\./, "")}"
      end

      user = DAOAccount.instance.fetch_account(session[:user])
      organisation = user.create_organisation(Sanitize.clean(params[:name]), Sanitize.clean(params[:description]), file_path)

      new_limit = params[:limit]
      if new_limit == ""
        organisation.limit = nil
      else
        organisation.limit = new_limit.to_i
      end
      organisation.reset_member_limits

      session[:alert] = Alert.create("Success!", "You created a new organisation.", false)
      redirect '/organisations/self'
    end

    ###
    #
    #  Switches from a user to an organisation or vice-versa.
    #  Called by organisation_switch.haml.
    #  At the moment there is a problem. If you are using this
    #  post you can add yourself to an organisation although you
    #  are not a member.
    #
    #  Expects:
    #  params[:account] : id of the account(user/org.) the user wants to switch to
    #
    #  TODO: Check that the user is aloud to change to this organisation!
    #
    ###

    post '/organisation/switch' do
      session[:account] = params[:account].to_i
      new_account = DAOAccount.instance.fetch_account(session[:account])

      session[:alert] = Alert.create("Success!", "You changed to " + new_account.name + ". You can now buy and sell items in its name.", false)
      redirect '/home'
    end

    ##
    #
    #  Shows all organisations a user is part off
    #
    #  Expects:
    #  session[:navigation] : has to be initilized
    #  session[:user] : id of the user
    #
    ##
    get '/organisations/self' do
      session[:navigation][:selected]  = "home"
      session[:navigation][:subnavigation] = "organisations"

      user = DAOAccount.instance.fetch_account(session[:user])
      haml :'organisation/self', :locals => { :all_organisations => DAOAccount.instance.fetch_organisations_of(user.id) }
    end

    ##
    #
    #  Shows all members of an organisation
    #
    #  Expects:
    #  sessions[:navigation] : has to be initialized
    #  session[:account] : id of the org. the user currently acts upon
    #  session[:user] : id of the user
    #
    ##
    get '/organisation/members' do
      session[:navigation][:selected]  = "home"
      session[:navigation][:subnavigation] = "members"

      organisation = DAOAccount.instance.fetch_account(session[:account])
      admin_view = organisation.is_admin?(DAOAccount.instance.fetch_account(session[:user]))
      haml :'organisation/members', :locals => { :all_members => organisation.members_without_admins, :all_admins => organisation.admins.values, :admin_view => admin_view }
    end

    ##
    #
    #  Shows all organisations in the system, except the organisation
    #  that the user is currently acting as
    #
    #  Expects:
    #  session[:account] : id of the org. the user currently acts upon
    #  sessions[:navigation] : has to be initialized
    #
    ##
    get '/organisations/all' do
      session[:navigation][:selected]  = "community"
      session[:navigation][:subnavigation] = "organisations"

      organisation = session[:account]
      haml :'organisation/all', :locals => { :all_organisations => DAOAccount.instance.fetch_organisations_but(organisation) }
    end

    ##
    #
    #  Shows the profile information of specific organisation
    #
    #  Expects:
    #  params[:id] : the organisation id
    #
    ##
    get '/organisations/:id' do
      organisation_id = params[:id]
      haml :'organisation/id', :locals => {:active_items => DAOAccount.instance.fetch_account(organisation_id.to_i).list_active_items}
    end

    ##
    #
    #  Shows a confirmation page if the user really wants to leave the organisation
    #
    #  Redirects:
    #  /home when the user isn't acting as an organisation or when he is the last admin
    #
    #  Expects:
    #  session[:user] : the id of the user who wants to leave
    #  session[:account] : the user's current id (his own or an organisation's)
    #
    ##
    get '/organisation/leave' do
      error_redirect("Oh no!", "You can't leave an organisation when you're not in your Organisations Profile.", session[:user] == session[:account], "/home")
      organisation = DAOAccount.instance.fetch_account(session[:account])
      is_admin = organisation.is_admin?(DAOAccount.instance.fetch_account(session[:user]))
      only_admin = false
      only_admin = true if organisation.admin_count == 1
      error_redirect("Oh no!", "You can't leave this Organisation, because you're the only Administrator.", is_admin && only_admin, "/home")

      haml :'organisation/leave'
    end

    ##
    #  Leaving an Organisation permanently. At least one admin has to remain
    #
    #  Redirects:
    #  /home always
    #
    #  Expects:
    #  session[:user] : the id of the user who wants to leave
    #  session[:account] : the user's current id (his own or an organisation's)
    ##
    post '/organisation/leave' do
      error_redirect("No valid User", "Your email could not be found.", !DAOAccount.instance.email_exists?(params[:user_email]), "/home")
      error_redirect("Oh no!", "You can't leave an organisation when you're not in your Organisations Profile.", session[:user] == session[:account], "/home")

      organisation = DAOAccount.instance.fetch_account(session[:account])
      is_admin = organisation.is_admin?(DAOAccount.instance.fetch_account(session[:user]))
      only_admin = false
      only_admin = true if organisation.admin_count == 1
      error_redirect("Oh no!", "You can't leave this Organisation, because you're the only Administrator.", is_admin && only_admin, "/home")

      user = DAOAccount.instance.fetch_account(session[:user])
      error_redirect("Oh no!", "You're trying to remove an other User from the Organisation.", params[:user_email] != user.email, "/home")

      organisation.remove_member_by_email(user.email)

      session[:account] = session[:user]
      redirect "/home"
    end

    ##
    # Shows the confirmation page if the user really wants to delete the organisation
    #
    # Redirect:
    # /home when the user is no admin
    #
    # Expects:
    # session[:user] : the id of the user who wants to delete the org.
    # session[:account] : the org. on which behalf the user acts upon
    # TODO: This should go to organisation_admin.rb!
    ##
    get '/organisation/delete' do
      error_redirect("Oh no!", "You can't delete this Organisation, because you're not an Administrator.", !DAOAccount.instance.fetch_account(session[:account]).is_admin?(DAOAccount.instance.fetch_account(session[:user])), "/home")
      haml :'organisation/delete'
    end

  ##
  # Deletes the organisation
  #
  # Redirect:
  # /home when the user is no admin
  #
  # Expects:
  # session[:user] : the id of the user who wants to delete the org.
  # session[:account] : the org. on which behalf the user acts upon
  # TODO: This should go to organisation_admin.rb!
  ##
    post '/organisation/delete' do
      error_redirect("Oh no!", "There is something gone wrong.", !DAOAccount.instance.account_exists?(session[:user]), "/home")
      error_redirect("Oh no!", "You can't delete this Organisation, because you're not an Administrator.", !DAOAccount.instance.fetch_account(session[:account]).is_admin?(DAOAccount.instance.fetch_account(session[:user])), "/home")

      org = DAOAccount.instance.fetch_account(session[:account])
      DAOAccount.instance.remove_account(org.id)

      user = session[:user]
      session[:account] = DAOAccount.instance.fetch_account(user).id

      redirect '/home'
    end
  end
end

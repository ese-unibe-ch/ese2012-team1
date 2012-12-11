include Models
include Helpers

##
# In this controller all profile edit requests are handled.
# There are two get- and postmethods, two to edit a user profile and
# two to edit an organisation profile.
##


module Controllers
  class AccountEdit < Sinatra::Application
    set :views, "#{absolute_path('../views', __FILE__)}"

    ##
    # This is used to change the profile of  a user.
    # Loads the form in edit_profile.haml and includes passwordchecker.js to do
    # realtime checking of the password typed in.
    #
    # Expected:
    # session[:navigation] has to be initialized
    #
    ##

    get '/account/edit/user/profile' do
      before_for_user_authenticated
      session[:navigation].get_selected.select_by_name("home")
      session[:navigation].get_selected.subnavigation.select_by_name("edit profile")

      haml :'user/edit_profile', :locals => {:script => 'passwordchecker.js', :onload => 'initialize()'}
    end

    ##
    #
    # Gets edited profile data from user. Redirected from edit_profile.haml with
    # Form. Checks if incoming data is correct and redirects to home.
    #
    # Redirects:
    # /account/edit/user/profile when a wrong email address was entered
    # /home when everything is correct
    #
    # Expected:
    # param[:password] : User password
    # param[:email] : User e-mail
    # optional param[:description] : A description of the user
    # optional param[:avatar] : A file for the avatar
    #
    ##

    post '/account/edit/user/profile' do
      before_for_user_authenticated

      user = Models::System.instance.fetch_account(session[:user])
      session[:email_error] = nil
      #Error Messages Sessions
      if params[:email] != nil
        newMailUser = Models::System.instance.fetch_user_by_email(params[:email])
        if newMailUser != nil
          session[:email_error] = "You entered a e-mail which is already in use." if (newMailUser != user)
          session[:is_email_error] = "yes" if (newMailUser != user)
        end
        session[:email_error] = "You entered a incorrect e-mail address" if params[:email] == "" || !params[:email].is_email?
        session[:is_email_error] = "yes" if params[:email] == "" || !params[:email].is_email?
      end

      if !session[:email_error].nil?
        redirect '/account/edit/user/profile'
      end


      session[:is_email_error] = ""

      if !params[:password].nil?
        user.password(params[:password])
      end
      if !params[:email].nil?
        user.email = params[:email]
      end

      if !params[:interests].nil?
        user.description = params[:interests].nil? ? "" : Sanitize.clean(params[:interests])
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

      redirect '/home'
    end

    ##
    #
    # Loads edit.haml where user can enter the new organisation profile.
    # Only for admins.
    #
    # Expected:
    # session[:navigation] : has to be initialized
    #
    ##
    get '/account/edit/organisation/profile' do
      before_for_admin

      session[:navigation].get_selected.select_by_name("home")
      session[:navigation].get_selected.subnavigation.select_by_name("edit organisation")

      haml :'organisation/edit'
    end

    ##
    #
    # Gets edited profile data from an organisation. Redirected from edit.haml with
    # Form. Checks if incoming data is correct and redirects to home. Resets remaining
    # limits of members if limit was changed. Only for admins.
    #
    # Redirects:
    # /error/Wrong_Limit when the limit isn't a number or is nil
    # /account/edit/user/profile when a wrong email address was entered
    # /home when everything is correct
    #
    # Expected:
    # session[:account] : the organisation id
    # param[:credit_limit] : maximum credits a non admin can spend per day
    # optional param[:description] : A description of the org.
    # optional param[:avatar] : A file for the avatar
    #
    ##
    post '/account/edit/organisation/profile' do
      before_for_admin

      organisation = Models::System.instance.fetch_account(session[:account])
      redirect "/error/Wrong_Limit" if params[:credit_limit] != "" && !(/^[\d]+(\.[\d]+){0,1}$/.match(params[:credit_limit]))

      if !params[:description].nil?
        organisation.description = params[:description].nil? ? "" : Sanitize.clean(params[:description])
      end

      old_limit = organisation.limit
      new_limit = params[:credit_limit]
      if old_limit != new_limit
        if new_limit == ""
          organisation.limit = nil
        else
          organisation.limit = new_limit.to_i
        end
        organisation.reset_member_limits
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

      redirect '/home'
    end
  end
end
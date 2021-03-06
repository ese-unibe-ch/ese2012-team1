include Models
include Helpers

##
#
# In this controller are all posts and gets needed for the creation of a new user handled
#
##
module Controllers
  class Registration < Sinatra::Application
    before do
      before_for_user_not_authenticated
    end

    set :views , "#{absolute_path('../views', __FILE__)}"

    ##
    # activates a user
    #
    # Redirects:
    # /error/Already_Activated when this user is already activated
    # /error/Wrong_Activation_Code when the sent hash doesn't exist
    #
    # Expects:
    # session[:user] : user who request a deletion of someone
    # session[:account] : id of the organisation
    # params[:reg_hash] : hash used to activate the user
    #
    ##
    get '/registration/confirm/:reg_hash' do
      hash = params[:reg_hash]
      error_redirect("Error!", "No such activation code. Try with copy and paste the complete URL from the e-mail into your Browser.", !DAOAccount.instance.reg_hash_exists?(hash), "/login")
      user = DAOAccount.instance.fetch_user_by_reg_hash(hash)
      error_redirect("Error!", "Your account is already activated. Please login.", user.activated, "/login")
      user.activate

      session[:alert] = Alert.create("Activation successful!", "Your account is now activated. Please login.", false)

      haml :'authentication/login'
    end


    ##
    #
    # Shows register form and includes passwordchecker.js to do
    # realtime checking of the password typed in.
    #
    # Expects:
    # session[:navigation] : has to be initialized
    #
    ##

    get '/register' do
      session[:navigation][:context] = :unregistered
      session[:navigation][:selected] = "register"
      haml :'authentication/register', :locals => { :script => 'passwordchecker.js', :onload => 'initialize()' }
    end


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


    ##
    #
    # Gets registration data from user. Redirected from register.haml with
    # Form. Checks if incoming data is correct and redirects to login. If
    # data is correct redirect to '/register'.
    #
    # Redirects:
    # /register when the entered data is incorrect(e.g. a not optional field is nil)
    # /register/successful when everything is correct
    #
    # Expected:
    # params[:name] : User name
    # params[:password] : User password
    # params[:email] : User e-mail
    # optional params[:description] : A description of the user
    # optional params[:avatar] : A file for the avatar
    #
    ##
    post '/register' do
      if are_nil?(params[:password], params[:re_password], params[:email], params[:name]) ||
         ! params[:password].is_strong_password? || params[:password] != params[:re_password] ||
          params[:email] == "" || ! params[:email].is_email? || params[:name] == "" || DAOAccount.instance.email_exists?(params[:email])

        #Error Messages Sessions
        session[:email_error] = ""
        session[:email_error] = "E-Mail Address already in use." if DAOAccount.instance.email_exists?(params[:email])
        session[:email_error] = "Not a correct E-Mail Address" if params[:email] == "" || !params[:email].is_email?
        session[:is_email_error] = "yes" if DAOAccount.instance.email_exists?(params[:email])
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
      email = Sanitize.clean(params[:email])
      description = params[:interests].nil? ? "" : Sanitize.clean(params[:interests])
      name = Sanitize.clean(params[:name])

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

      if request.port == 443
        address = "https://#{request.host}"
      else
        address = "http://#{request.host}:#{request.port}"
      end
      Mailer.setup.sendRegMail(user.id, address)
      session[:alert] = Alert.create("Your registration was successful!", "Now you have to activate your account by clicking on the link in the mail we sent you.", false)

      redirect "/login"
    end



    ##
    #
    # Shows a confirmation page if the user really wants to delete his account
    #
    # Redirects:
    # / when the user is not logged in
    #
    ##
    get '/unregister' do
      redirect "/" unless session[:auth]
      haml :'authentication/unregister'
    end

    ##
    #
    # Deletes user from the system and logs him out, if he isn't
    # the only admin of an organisation.
    #
    # Redirects:
    # /error/No_Valid_Account_Id when the user id couldn't be found
    # /home when this user is the only admin of an org.
    # /unauthenticate when everything is correct
    #
    #
    # Expected:
    # session[:user] id of the user who wants to delete his account
    #
    ##
    post '/unregister' do
      redirect "/" unless session[:auth]
      error_redirect("Oh, no!", "Something went wrong.", !DAOAccount.instance.account_exists?(session[:user]), "/home")
      user = DAOAccount.instance.fetch_account(session[:user])

      # Do Organisation Check
      deletable = ! DAOAccount.instance.is_last_admin?(user)

      # Remove User From Organisation
      if deletable
        org_list = DAOAccount.instance.fetch_organisations_of(user.id)

        for org in org_list do
          org.remove_member(user)
        end
      else
        session[:alert] = Alert.create("Oh no!", "You can't delete your Account, because you're the only Admin of one of your Organisations.", true)
        redirect "/home"
      end

      user.clear
      session.clear

      redirect '/'
    end
  end
end
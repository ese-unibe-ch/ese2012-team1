include Models
include Helpers

##
#
#  In this class all requests and actions that only an org. admin
#  can do are handled.
#
##
module Controllers
  class OrganisationAdmin < Sinatra::Application

    before do
      before_for_admin
    end

    ##
    #
    # After this the user sees a form where he can specify who he wants
    # to add to the organisation.
    #
    # Expects:
    # session[:navigation] : has to be initialized
    #
    ##
    get '/organisation/add/member' do
      session[:navigation][:selected]  = "home"
      session[:navigation][:subnavigation] = "add member"

      haml :'organisation/add_member'
    end

    ##
    #
    # Called by user_add_member.haml via form.
    # Shows a confirmation page after successful identification.
    # Stay on the same page if specified Email couldn't be found.
    #
    # Expects:
    # params[:member] : email of user to be added
    #
    ##
    post '/organisation/add/member' do
      if DAOAccount.instance.email_exists?(params[:member])
        haml :'organisation/member_confirm', :locals => { :member => params[:member]}
      else
        session[:alert] = Alert.create("Oh no!", "User with email #{params[:member]} does not exist!", true)
        haml :'organisation/add_member'
      end
    end

    ##
    #
    # Adds the user to the organisation
    #
    # Redirect:
    # /home when the user is no admin
    #
    # Expects:
    # params[:member] : user who should be added to the org.
    # session[:account] : the organisation
    #
    ##
    post '/organisation/member/confirm' do
      if DAOAccount.instance.email_exists?(params[:member])
        user =  DAOAccount.instance.fetch_user_by_email(params[:member])
        org = DAOAccount.instance.fetch_account(session[:account])
        org.add_member(user)

        session[:alert] = Alert.create("Success!", "You added user #{params[:member]}", false)
        haml :'organisation/add_member'
      else
        session[:alert] = Alert.create("Oh no!", "User with e-mail #{params[:member]} does not exist!", true)
        haml :'organisation/add_member'
      end
    end


    ##
    #
    # If everything is alright displays a confirmation page
    # else goes back to the member list. Called by members.haml via form.
    #
    # Redirects:
    # /organisation/members when last admin wants to delete himself
    #                       or when the member who should be deleted does not exists
    #
    # Expects:
    # session[:user] : user who request a deletion of someone
    # session[:account] : id of the organisation
    # params[:member] : email of user to be deleted
    #
    ##
    post '/organisation/member/delete' do
      self_remove = (DAOAccount.instance.fetch_account(session[:user]) == DAOAccount.instance.fetch_user_by_email(params[:member]))
      organisation = DAOAccount.instance.fetch_account(session[:account])
      only_admin = true if organisation.admin_count == 1
      if self_remove && only_admin
        session[:alert] = Alert.create("Oh no!", "You can't leave this Organisation, because you're the only Administrator.", true)
        redirect "/organisation/members"
      end
      if DAOAccount.instance.email_exists?(params[:member])
        haml :'organisation/member_delete_confirm', :locals => { :member => params[:member]}
      else
        redirect 'organisation/members', :locals => { :error_message => "User does not exist" }
      end
    end

    ##
    #
    # If this is confirmed a member is deleted from an organisation.
    #
    # Redirects:
    # /organisation/members when last admin wants to delete himself
    #                       or when the member who should be deleted could not be found
    # /home when an admin removed himself
    # /organisations/members when an admin removed someone else
    #
    # Expects:
    # session[:user] : user who request a deletion of someone
    # session[:account] : id of the organisation
    # params[:user_email] : email of user to be deleted
    #
    ##
    post '/organisation/member/delete/confirm' do
      self_remove = (DAOAccount.instance.fetch_account(session[:user]) == DAOAccount.instance.fetch_user_by_email(params[:user_email]))
      organisation = DAOAccount.instance.fetch_account(session[:account])
      only_admin = true if organisation.admin_count == 1
      if self_remove && only_admin
        session[:alert] = Alert.create("Oh no!", "You can't leave this Organisation, because you're the only Administrator.", true)
        redirect "/organisation/members"
      end
      unless DAOAccount.instance.email_exists?(params[:user_email])
        session[:alert] = Alert.create("Oh no!", "This is not a valid User.", true)
        redirect "/organisation/members"
      end
      user = DAOAccount.instance.fetch_user_by_email(params[:user_email])
      organisation.remove_member_by_email(user.email)

      if self_remove
        session[:account] = session[:user]
        redirect '/home'
      else
        redirect '/organisation/members'
      end
    end

    ##
    #
    # Shows confirmation form for providing admin privileges to normal member.
    #
    # Redirects:
    # /organisation/members when the user is already an admin
    #                       or when the user does not exists
    #
    # Expects:
    # session[:account] : organisation id
    # session[:user] : user who requests a promotion of someone
    # params[:member] : email of user to be promoted
    #
    ##
    post '/organisation/member/to_admin' do
      if DAOAccount.instance.fetch_account(session[:account]).is_admin?(DAOAccount.instance.fetch_user_by_email(params[:member]))
        session[:alert] = Alert.create("Oh no!", "This user is already an Administrator of this Organisation.", true)
        redirect "/organisation/members"
      end

      if DAOAccount.instance.email_exists?(params[:member])
        haml :'organisation/member_to_admin_confirm', :locals => { :member => params[:member]}
      else
        redirect '/organisation/members'
      end
    end

    ##
    #
    # Provides admin privileges to normal member.
    #
    # Redirects:
    # /organisation/members
    #
    # Expects:
    # session[:account] : organisation id
    # session[:user] : user who requests a promotion of someone
    # params[:user_email] : email of user to be promoted
    #
    ##
    post '/organisation/member/to_admin/confirm' do
      if DAOAccount.instance.fetch_account(session[:account]).is_admin?(DAOAccount.instance.fetch_user_by_email(params[:user_email]))
        session[:alert] = Alert.create("Oh no!", "This user is already an Administrator of this Organisation.", true)
        redirect "/organisation/members"
      end

      organisation = DAOAccount.instance.fetch_account(session[:account])
      user = DAOAccount.instance.fetch_user_by_email(params[:user_email])
      if user.id != session[:user]
        organisation.set_as_admin(user)
      end

      redirect '/organisation/members'
    end

    ##
    #
    # Shows confirmation form for revoking admin privileges from admin user
    #
    # Redirects:
    # /organisation/members when the last admin would be degraded
    #                       or when the member to be degraded does not exists
    #
    # Expects:
    # session[:account] : organisation id
    # session[:user] : user who request a downgrade of someone
    # params[:member] : email of the user to be downgraded
    #
    ##

    post '/organisation/admin/to_member' do
      self_revoke = (DAOAccount.instance.fetch_account(session[:user]) == DAOAccount.instance.fetch_user_by_email(params[:member]))
      organisation = DAOAccount.instance.fetch_account(session[:account])
      only_admin = true if organisation.admin_count == 1
      if self_revoke && only_admin
        session[:alert] = Alert.create("Oh no!", "You can not revoke administrator privileges from yourself if you are the only Administrator of an Organisation.", true)
        redirect "/organisation/members"
      end
      if DAOAccount.instance.email_exists?(params[:member])
        haml :'organisation/admin_to_member_confirm', :locals => { :member => params[:member]}
      else
        redirect '/organisation/members'
      end
    end

    ##
    #
    # Revokes admin privileges from an organisation admin
    #
    # Redirects:
    # /organisation/members when there would be no admin left
    #                       or when the admin who should be degraded could not be found
    # /home when an admin degraded himself
    # /organisations/members when an admin degraded someone else
    #
    # Expects:
    # session[:user] : user who request a degrade of someone
    # session[:account] : id of the organisation
    # params[:user_email] : email of user to be degraded
    #
    ##
    post '/organisation/admin/to_member/confirm' do
      unless DAOAccount.instance.fetch_account(session[:account]).is_admin?(DAOAccount.instance.fetch_account(session[:user]))
        session[:alert] = Alert.create("Oh no!", "You're not an administrator of this Organisation.", true)
        redirect "/organisation/members"
      end

      self_revoke = (DAOAccount.instance.fetch_account(session[:user]) == DAOAccount.instance.fetch_user_by_email(params[:user_email]))
      organisation = DAOAccount.instance.fetch_account(session[:account])
      only_admin = true if organisation.admin_count == 1
      if self_revoke && only_admin
        session[:alert] = Alert.create("Oh no!", "You can not revoke administrator privileges from yourself if you are the only Administrator of an Organisation.", true)
        redirect "/organisation/members"
      end

      user = DAOAccount.instance.fetch_user_by_email(params[:user_email])
      organisation.revoke_admin_rights(user)

      if user.id == session[:user]
        redirect '/home'
      else
        redirect '/organisation/members'
      end
    end

  end
end
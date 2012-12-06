require 'rubygems'
require 'require_relative'
require 'sinatra/base'
require 'haml'
require 'sinatra/content_for'
require_relative('../models/user')
require_relative('../models/item')
require_relative('../helpers/render')
require_relative '../helpers/before'
require_relative('../helpers/string_checkers')

include Models
include Helpers

module Controllers
  class OrganisationAdmin < Sinatra::Application

    before do
      before_for_admin
    end

    get '/organisation/add/member' do
      session[:navigation].get_selected.select_by_name("home")
      session[:navigation].get_selected.subnavigation.select_by_name("add member")

      haml :'organisation/add_member'
    end

    ##
    #
    # Called by user_add_member.haml via form
    #
    # Expects:
    # params[:member] : email of user to be added
    #
    ##

    post '/organisation/add/member' do
      if Models::System.instance.user_exists?(params[:member])
        haml :'organisation/member_confirm', :locals => { :member => params[:member]}
      else
        session[:alert] = Alert.create("Oh no!", "User with email #{params[:member]} does not exist!", true)
        haml :'organisation/add_member'
      end
    end

    post '/organisation/member/confirm' do
      if Models::System.instance.user_exists?(params[:member])
        user =  Models::System.instance.fetch_user_by_email(params[:member])
        org = Models::System.instance.fetch_account(session[:account])
        org.add_member(user)

        session[:alert] = Alert.create("Success!", "You added user #{params[:member]}", false)
        haml :'organisation/add_member'
      else
        session[:alert] = Alert.create("Oh no!", "User with e-mail #{params[:member]} does not exist!", true)
        haml :'organisation/add_member'
      end
    end


    ##
    # Called by members.haml via form
    #
    # Expects:
    # params[:member] : email of user to be deleted
    ##

    post '/organisation/member/delete' do
      self_remove = (Models::System.instance.fetch_account(session[:user]) == Models::System.instance.fetch_user_by_email(params[:member]))
      organisation = Models::System.instance.fetch_account(session[:account])
      only_admin = true if organisation.admin_count == 1
      if self_remove && only_admin
        session[:alert] = Alert.create("Oh no!", "You can't leave this Organisation, because you're the only Administrator.", true)
        redirect "/organisation/members"
      end
      if Models::System.instance.user_exists?(params[:member])
        haml :'organisation/member_delete_confirm', :locals => { :member => params[:member]}
      else
        redirect 'organisation/members', :locals => { :error_message => "User does not exist" }
      end
    end


    post '/organisation/member/delete/confirm' do
      self_remove = (Models::System.instance.fetch_account(session[:user]) == Models::System.instance.fetch_user_by_email(params[:user_email]))
      organisation = Models::System.instance.fetch_account(session[:account])
      only_admin = true if organisation.admin_count == 1
      if self_remove && only_admin
        session[:alert] = Alert.create("Oh no!", "You can't leave this Organisation, because you're the only Administrator.", true)
        redirect "/organisation/members"
      end
      unless Models::System.instance.user_exists?(params[:user_email])
        session[:alert] = Alert.create("Oh no!", "This is not a valid User.", true)
        redirect "/organisation/members"
      end
      user = Models::System.instance.fetch_user_by_email(params[:user_email])
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
    # Confirmation form for providing admin privileges to normal user.
    #
    ##
    post '/organisation/member/to_admin' do
      if Models::System.instance.fetch_account(session[:account]).is_admin?(Models::System.instance.fetch_user_by_email(params[:member]))
        session[:alert] = Alert.create("Oh no!", "This user is already an Administrator of this Organisation.", true)
        redirect "/organisation/members"
      end

      if Models::System.instance.user_exists?(params[:member])
        haml :'organisation/member_to_admin_confirm', :locals => { :member => params[:member]}
      else
        redirect '/organisation/members'
      end
    end

    post '/organisation/member/to_admin/confirm' do
      if Models::System.instance.fetch_account(session[:account]).is_admin?(Models::System.instance.fetch_user_by_email(params[:user_email]))
        session[:alert] = Alert.create("Oh no!", "This user is already an Administrator of this Organisation.", true)
        redirect "/organisation/members"
      end

      organisation = Models::System.instance.fetch_account(session[:account])
      user = Models::System.instance.fetch_user_by_email(params[:user_email])
      if user.id != session[:user]
        organisation.set_as_admin(user)
      end

      redirect '/organisation/members'
    end

    ##
    #
    # Confirmation form for revoking admin privileges from admin user
    #
    ##

    post '/organisation/admin/to_member' do
      self_revoke = (Models::System.instance.fetch_account(session[:user]) == Models::System.instance.fetch_user_by_email(params[:member]))
      organisation = Models::System.instance.fetch_account(session[:account])
      only_admin = true if organisation.admin_count == 1
      if self_revoke && only_admin
        session[:alert] = Alert.create("Oh no!", "You can not revoke administrator privileges from yourself if you are the only Administrator of an Organisation.", true)
        redirect "/organisation/members"
      end
      if Models::System.instance.user_exists?(params[:member])
        haml :'organisation/admin_to_member_confirm', :locals => { :member => params[:member]}
      else
        redirect '/organisation/members'
      end
    end

    post '/organisation/admin/to_member/confirm' do
      unless Models::System.instance.fetch_account(session[:account]).is_admin?(Models::System.instance.fetch_account(session[:user]))
        session[:alert] = Alert.create("Oh no!", "You're not an administrator of this Organisation.", true)
        redirect "/organisation/members"
      end

      self_revoke = (Models::System.instance.fetch_account(session[:user]) == Models::System.instance.fetch_user_by_email(params[:user_email]))
      organisation = Models::System.instance.fetch_account(session[:account])
      only_admin = true if organisation.admin_count == 1
      if self_revoke && only_admin
        session[:alert] = Alert.create("Oh no!", "You can not revoke administrator privileges from yourself if you are the only Administrator of an Organisation.", true)
        redirect "/organisation/members"
      end

      user = Models::System.instance.fetch_user_by_email(params[:user_email])
      organisation.revoke_admin_rights(user)

      if user.id == session[:user]
        redirect '/home'
      else
        redirect '/organisation/members'
      end
    end

  end
end
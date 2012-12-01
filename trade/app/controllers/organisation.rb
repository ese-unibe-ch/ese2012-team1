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
      @error[:name] = ErrorMessages.get("Choose_Another_Name") if Models::System.instance.organisation_exists?(params[:name])
      @error[:limit] = ErrorMessages.get("Wrong_Limit") if params[:limit] != "" && !(/^[\d]+(\.[\d]+){0,1}$/.match(params[:limit]))

      unless (@error.empty?)
        puts @error
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

      user = Models::System.instance.fetch_account(session[:user])
      organisation = user.create_organisation(params[:name], params[:description], file_path)

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
#  params[:account] : id of the account the user wants to switch to
#
#  TODO: Check that the user is aloud to change to this organisation!
#
###

    post '/organisation/switch' do
      session[:account] = params[:account].to_i
      new_account = System.instance.fetch_account(session[:account])

      session[:alert] = Alert.create("Success!", "You changed to " + new_account.name + ". You can now buy and sell items in its name.", false)
      redirect '/home'
    end

    get '/organisations/self' do
      session[:navigation].get_selected.select_by_name("home")
      session[:navigation].get_selected.subnavigation.select_by_name("organisations")

      user = Models::System.instance.fetch_account(session[:user])
      haml :'organisation/self', :locals => { :all_organisations => Models::System.instance.fetch_organisations_of(user.id) }
    end

    get '/organisation/members' do
      session[:navigation].get_selected.select_by_name("home")
      session[:navigation].get_selected.subnavigation.select_by_name("members")

      organisation = Models::System.instance.fetch_account(session[:account])
      admin_view = organisation.is_admin?(Models::System.instance.fetch_account(session[:user]))
      haml :'organisation/members', :locals => { :all_members => organisation.members_without_admins, :all_admins => organisation.admins.values, :admin_view => admin_view }
    end

    get '/organisations/all' do
      session[:navigation].get_selected.select_by_name("community")
      session[:navigation].get_selected.subnavigation.select_by_name("organisations")

      organisation = session[:account]
      haml :'organisation/all', :locals => { :all_organisations => Models::System.instance.fetch_organisations_but(organisation) }
    end

    get '/organisations/:id' do
      organisation_id = params[:id]
      haml :'organisation/id', :locals => {:active_items => Models::System.instance.fetch_account(organisation_id.to_i).list_active_items}
    end

    ##
    # Leaving an Organisation
    ##
    get '/organisation/leave' do
      redirect "/error/Not_In_Organisation" if session[:user] == session[:account]
      organisation = Models::System.instance.fetch_account(session[:account])
      is_admin = organisation.is_admin?(Models::System.instance.fetch_account(session[:user]))
      only_admin = true if organisation.admin_count == 1
      redirect "/error/No_Self_Remove" if is_admin && only_admin

      haml :'organisation/leave'
    end

    post '/organisation/leave' do
      redirect "/error/Not_In_Organisation" if session[:user] == session[:account]
      redirect "/error/No_Valid_User" unless Models::System.instance.user_exists?(params[:user_email])
      organisation = Models::System.instance.fetch_account(session[:account])
      is_admin = organisation.is_admin?(Models::System.instance.fetch_account(session[:user]))
      only_admin = true if organisation.admin_count == 1
      redirect "/error/No_Self_Remove" if is_admin && only_admin

      user = Models::System.instance.fetch_user_by_email(params[:user_email])
      redirect "/error/Try_Remove_Other" if params[:user_email] != user.email

      organisation.remove_member_by_email(user.email)

      session[:account] = session[:user]
      redirect "/home"
    end

    ##
    # Deleting an Organisation
    # TODO: This should go to organisation_admin.rb!
    ##
    get '/organisation/delete' do
      redirect "/error/Not_an_Admin" unless Models::System.instance.fetch_account(session[:account]).is_admin?(Models::System.instance.fetch_account(session[:user]))
      haml :'organisation/delete'
    end

    post '/organisation/delete' do
      redirect "/error/No_Valid_Account_Id" unless Models::System.instance.account_exists?(session[:user])
      redirect "/error/Not_an_Admin" unless Models::System.instance.fetch_account(session[:account]).is_admin?(Models::System.instance.fetch_account(session[:user]))
      org = Models::System.instance.fetch_account(session[:account])
      Models::System.instance.remove_account(org.id)

      user = session[:user]
      session[:account] = Models::System.instance.fetch_account(user).id

      redirect '/home'
    end
  end
end

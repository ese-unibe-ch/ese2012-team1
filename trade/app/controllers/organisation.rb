require 'rubygems'
require 'require_relative'
require 'sinatra/base'
require 'haml'
require 'sinatra/content_for'
require_relative('../models/user')
require_relative('../models/item')
require_relative('../helpers/render')
require_relative('../helpers/string_checkers')

include Models
include Helpers

module Controllers
  class Organisation < Sinatra::Application
    set :views, "#{absolute_path('../views', __FILE__)}"

    set :raise_errors, false unless development?
    set :show_exceptions, false unless development?

    before do
      redirect "/" unless session[:auth]
      response.headers['Cache-Control'] = 'public, max-age=0'
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
#
#  optional params[:avatar] : Picture for organisation
#
##

    post '/organisation/create' do
      redirect "/error/No_Valid_Account_Id" unless Models::System.instance.account_exists?(session[:user])
      redirect "/error/No_Name" if params[:name].nil? or params[:name]==''
      redirect "/error/No_Description" if params[:description].nil? or params[:description]==''
      redirect "/error/Choose_Another_Name" if Models::System.instance.organisation_exists?(params[:name])

      fail "Should have description" if params[:description].nil?
      fail "Should have name" if params[:name].nil?

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
      user.create_organisation(params[:name], params[:description], file_path)

      redirect '/home'
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
###

    post '/organisation/switch' do
      session[:account] = params[:account].to_i

      redirect '/home'
    end

    get '/organisation/members' do
      #only checks if :account is in the range of valid ids
      redirect "/error/No_Valid_Account_Id" unless Models::System.instance.account_exists?(session[:account])

      Navigations.get_selected.select_by_name("home")
      Navigations.get_selected.subnavigation.select_by_name("members")

      organisation = Models::System.instance.fetch_account(session[:account])
      haml :'organisation/members', :locals => { :all_members => organisation.members.values }
    end

    get '/organisation/add/member' do
      Navigations.get_selected.select_by_name("home")
      Navigations.get_selected.subnavigation.select_by_name("add member")

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
      redirect "/error/No_Valid_Account_Id" unless Models::System.instance.account_exists?(session[:account])

      if Models::System.instance.user_exists?(params[:member])
        haml :'organisation/member_confirm', :locals => { :member => params[:member]}
      else
        haml :'organisation/add_member', :locals => { :error_message => "User does not exist" }
      end
    end

    post '/organisation/member/confirm' do
      redirect "/error/No_Valid_Account_Id" unless Models::System.instance.account_exists?(session[:account])
      if Models::System.instance.user_exists?(params[:member])
        user =  Models::System.instance.fetch_user_by_email(params[:member])
        org = Models::System.instance.fetch_account(session[:account])
        org.add_member(user)
        haml :'organisation/add_member', :locals => { :success_message => "User was successfully added"}
      else
        haml :'organisation/add_member', :locals => { :error_message => "User does not exist" }
      end
    end


    ##
    # Called by members.haml via form
    #
    # Expects:
    # params[:member] : email of user to be deleted
    ##

    post '/organisation/member/delete' do
      redirect "/error/No_Valid_Account_Id" unless Models::System.instance.account_exists?(session[:account])
      redirect "/error/No_Self_Remove" unless (Models::System.instance.fetch_account(session[:user]) != Models::System.instance.fetch_user_by_email(params[:member]))
      if Models::System.instance.user_exists?(params[:member])
        haml :'organisation/member_delete_confirm', :locals => { :member => params[:member]}
      else
        redirect 'organisation/members', :locals => { :error_message => "User does not exist" }
      end
    end


    post '/organisation/member/delete/confirm' do
      redirect "/error/No_Valid_Account_Id" unless Models::System.instance.account_exists?(session[:account])
      redirect "/error/No_Valid_User" unless Models::System.instance.user_exists?(params[:user_email])
      organisation = Models::System.instance.fetch_account(session[:account])
      user = Models::System.instance.fetch_user_by_email(params[:user_email])
      if user.id != session[:user]
        organisation.members.delete(user.email)
      end
      redirect '/organisation/members'
    end

    get '/organisations/self' do
      redirect "/error/No_Valid_Account_Id" unless Models::System.instance.account_exists?(session[:user])

      Navigations.get_selected.select_by_name("home")
      Navigations.get_selected.subnavigation.select_by_name("organisations")

      user = Models::System.instance.fetch_account(session[:user])
      haml :'organisation/self', :locals => { :all_organisations => Models::System.instance.fetch_organisations_of(user.id) }
    end

    get '/organisations/all' do
      redirect "/error/No_Valid_Account_Id" unless Models::System.instance.account_exists?(session[:account])

      Navigations.get_selected.select_by_name("community")
      Navigations.get_selected.subnavigation.select_by_name("organisations")

      organisation = session[:account]
      haml :'organisation/all', :locals => { :all_organisations => Models::System.instance.fetch_organisations_but(organisation) }
    end

    get '/organisations/:id' do
      redirect "/error/No_Valid_Account_Id" unless Models::System.instance.account_exists?(params[:id].to_i)
      organisation_id = params[:id]
      haml :'organisation/id', :locals => {:active_items => Models::System.instance.fetch_account(organisation_id.to_i).list_active_items}
    end

    error do
      haml :error, :locals => {:error_title => "", :error_message => "#{request.env['sinatra.error'].to_s}" }
    end

    get '/organisation/delete' do
      haml :'organisation/delete'
    end

    post '/organisation/delete' do
      redirect "/error/No_Valid_Account_Id" unless Models::System.instance.account_exists?(session[:account])
      redirect "/error/No_Valid_Account_Id" unless Models::System.instance.account_exists?(session[:user])
      org = Models::System.instance.fetch_account(session[:account])
      Models::System.instance.remove_account(org.id)

      user = session[:user]
      session[:account] = Models::System.instance.fetch_account(user).id

      redirect '/home'
    end
  end
end

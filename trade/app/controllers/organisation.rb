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
    end

    get '/organisation/create' do
      haml :organisation_create
    end

    post '/organisation/create' do
      fail "Should have name" if params[:name].nil?
      fail "Should have description" if params[:description].nil?

      user = Models::System.instance.fetch_account(session[:user])
      user.create_organisation(params[:name], params[:description], "../images/users/default_avatar.png")

      redirect '/home'
    end

    get '/organisations/all' do
      user = Models::System.instance.fetch_account(session[:user])
      haml :organisations_all, :locals => { :all_organisations => Models::System.instance.fetch_organisations_of(user.id) }
    end

    post '/organisation/switch' do
      user = Models::System.instance.fetch_account(session[:user])
      organisation_id = params[:account]

      if session[:user] == organisation_id
        session[:account] = user.id
      else
        organisation = Models::System.instance.fetch_account(organisation_id.to_i)
        session[:account] = organisation.id
      end

      redirect '/home'
    end

    get '/organisation/members' do
      organisation = Models::System.instance.fetch_account(session[:account])
      haml :organisation_members, :locals => { :all_members => organisation.users.values }
    end

    post '/organisation/members/remove' do
      organisation = Models::System.instance.fetch_account(session[:account])
      user = Models::System.instance.fetch_user_by_email(params[:user_email])
      if user.id != session[:user]
        organisation.users.delete(user.email)
      end
      redirect '/organisation/members'
    end

    get '/organisation/add/member' do
      haml :organisation_add_member
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
        user =  Models::System.instance.fetch_user_by_email(params[:member])
        org = Models::System.instance.fetch_account(session[:account])
        org.add_member(user)
        haml :organisation_add_member, :locals => { :success_message => "User was successfully added"}
      else
        haml :organisation_add_member, :locals => { :error_message => "User does not exist" }
      end

    end

    get '/organisations/self' do
      user = Models::System.instance.fetch_account(session[:user])
      haml :organisations_self, :locals => { :all_organisations => Models::System.instance.fetch_organisations_of(user.id) }
    end

    get '/organisations/all' do
      organisation = session[:account]
      haml :organisations_all, :locals => { :all_organisations => Models::System.instance.fetch_organisations_but(organisation) }
    end

    error do
      haml :error, :locals => {:error_title => "", :error_message => "#{request.env['sinatra.error'].to_s}" }
    end
  end
end
require 'rubygems'
require 'require_relative'
require 'sinatra/base'
require 'haml'
require 'sinatra/content_for'
require_relative('../models/user')
require_relative('../models/item')
require_relative('../helpers/render')

include Models
include Helpers

module Controllers
  class ItemSites < Sinatra::Application
    set :views , "#{absolute_path('../views', __FILE__)}"

    before do
      redirect "/" unless session[:auth]
      response.headers['Cache-Control'] = 'public, max-age=0'
      redirect "/error/No_Valid_Account_Id" unless Models::System.instance.account_exists?(session[:account])
    end

    get '/items/my/active' do
        user_id = session[:account]
        haml :'item/my_active', :locals => {:active_items => Models::System.instance.fetch_account(user_id).list_active_items}
    end

    get '/items/my/inactive' do
        user_id = session[:account]
        haml :'item/my_inactive', :locals => {:inactive_items => Models::System.instance.fetch_account(user_id).list_inactive_items}
    end

    get '/items/my/all' do
      Navigations.get_selected.select_by_name("home")
      Navigations.get_selected.subnavigation.select_by_name("items")

      account = Models::System.instance.fetch_account(session[:account])
      haml :'item/my_all', :locals => {:inactive_items => account.list_inactive_items,
                                       :active_items => account.list_active_items }
    end

    get '/item/create' do
       Navigations.get_selected.select_by_name("market")
       Navigations.get_selected.subnavigation.select_by_name("create item")

        haml :'item/create'
    end

    get '/item/comment/:id' do
      item = System.instance.fetch_item(params[:id].to_i)
      haml :'item/comments', :locals => {:item => item }
    end

    get '/items/active' do
        Navigations.get_selected.select_by_name("market")
        Navigations.get_selected.subnavigation.select_by_name("on sale")

        viewer_id = session[:account]
        haml :'item/active', :locals => {:all_items => Models::System.instance.fetch_all_active_items_but_of(viewer_id)}
    end

    get '/item/:id' do
      redirect "/error/No_Valid_Item_Id" unless Models::System.instance.item_exists?(params[:id])

      haml :'item/item', :locals => {:item => Models::System.instance.fetch_item(params[:id])}
    end

    get '/item/add/comment/:item_id/:comment_nr' do
      redirect "/error/No_Valid_Item_Id" unless Models::System.instance.item_exists?(params[:item_id])

      item = Models::System.instance.fetch_item(params[:item_id])

      haml :'item/comment', :locals => {:item => item, :comment_nr => params[:comment_nr]}
    end
  end
end
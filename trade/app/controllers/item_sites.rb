require 'rubygems'
require 'require_relative'
require 'sinatra/base'
require 'haml'
require 'sinatra/content_for'
require_relative('../models/user')
require_relative('../models/item')

require_relative('../helpers/render')
require_relative '../helpers/before'

include Models
include Helpers

module Controllers
  class ItemSites < Sinatra::Application
    before do
      before_for_user_authenticated
    end

    set :views , "#{absolute_path('../views', __FILE__)}"

    get '/items/my/active' do
        user_id = session[:account]
        haml :'item/my_active', :locals => {:active_items => Models::System.instance.fetch_account(user_id).list_active_items}
    end

    get '/items/my/inactive' do
        user_id = session[:account]
        haml :'item/my_inactive', :locals => {:inactive_items => Models::System.instance.fetch_account(user_id).list_inactive_items}
    end

    get '/item/wish/list' do
        user_id = session[:account]
        haml :'item/wish_list', :locals => {:wish_list => Models::System.instance.fetch_account(user_id).wish_list}
    end

    get '/items/my/all' do
      session[:navigation].get_selected.select_by_name("home")
      session[:navigation].get_selected.subnavigation.select_by_name("items")

      account = Models::System.instance.fetch_account(session[:account])

      haml :'item/my_all', :locals => {:inactive_items => account.list_inactive_items,
                                       :active_items => account.list_active_items}
    end

    get '/items/my/wishlist' do
      session[:navigation].get_selected.select_by_name("home")
      session[:navigation].get_selected.subnavigation.select_by_name("wishlist")

      account = Models::System.instance.fetch_account(session[:account])

      haml :'item/wish_list', :locals => {:wish_list_items => account.wish_list.items}
    end

    get '/item/create' do
       session[:navigation].get_selected.select_by_name("market")
       session[:navigation].get_selected.subnavigation.select_by_name("create item")

       haml :'item/create'
    end

    get '/item/comment/:id' do
      item = System.instance.fetch_item(params[:id].to_i)
      haml :'item/comments', :locals => {:item => item }
    end

    get '/items/active' do
        session[:navigation].get_selected.select_by_name("market")
        session[:navigation].get_selected.subnavigation.select_by_name("on sale")

        viewer_id = session[:account]
        haml :'item/active', :locals => {:all_items => Models::System.instance.fetch_all_active_items_but_of(viewer_id)}
    end

    get '/item/:id' do
      redirect "/error/No_Valid_Item_Id" unless Models::System.instance.item_exists?(params[:id])
      item = Models::System.instance.fetch_item(params[:id])
      if !item.is_active? && item.owner.id != session[:account]
        session[:alert] = Alert.create("Inactive Item", "The Item you try to watch isn't active.", true)
        redirect "/items/active"
      end

      haml :'item/item', :locals => {:item => item}
    end

    get '/item/add/comment/:item_id/:comment_nr' do
      redirect "/error/No_Valid_Item_Id" unless Models::System.instance.item_exists?(params[:item_id])

      item = Models::System.instance.fetch_item(params[:item_id])

      haml :'item/comment', :locals => {:item => item, :comment_nr => params[:comment_nr]}
    end

    get '/item/changestate/expiration' do
      item = Models::System.instance.fetch_item(params[:id])

      haml :'item/expiration', :locals => {:item => item}
    end

    get '/item/:id/edit' do
      before_for_item_manipulation

      id = params[:id]
      item = Models::System.instance.fetch_item(params[:id])
      name = item.name
      description = item.description
      description_list = item.description_list
      description_position = item.description_position
      price = item.price
      picture = item.picture

      haml :'item/edit', :locals => {:id => id, :name => name, :description => description, :description_list => description_list, :description_position => description_position, :price => price, :picture => picture}
    end
  end
end
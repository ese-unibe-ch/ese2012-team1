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

##
# In this controller are most pages that only display information
# of an item or multiple items.
##
module Controllers
  class ItemSites < Sinatra::Application
    before do
      before_for_user_authenticated
    end

    set :views , "#{absolute_path('../views', __FILE__)}"

    ##
    #  Shows all of your active items
    #
    #  Expects:
    #  session[:account] : your id as a user or organisation
    #
    ##
    get '/items/my/active' do
        user_id = session[:account]
        haml :'item/my_active', :locals => {:active_items => Models::System.instance.fetch_account(user_id).list_active_items}
    end

    ##
    #  Shows all of your inactive items
    #
    #  Expects:
    #  session[:account] : your id as a user or organisation
    #
    ##
    get '/items/my/inactive' do
        user_id = session[:account]
        haml :'item/my_inactive', :locals => {:inactive_items => Models::System.instance.fetch_account(user_id).list_inactive_items}
    end

    get '/item/wish/list' do
        user_id = session[:account]
        haml :'item/wish_list', :locals => {:wish_list => Models::System.instance.fetch_account(user_id).wish_list}
    end

    ##
    #  Shows both your active and your inactive items
    #
    #  Expects:
    #  session[:navigation] : has to be initialized
    #  session[:account] : your id as a user or organisation
    #
    ##
    get '/items/my/all' do
      session[:navigation][:selected]  = "home"
      session[:navigation][:subnavigation]  = "items"

      account = Models::System.instance.fetch_account(session[:account])

      haml :'item/my_all', :locals => {:inactive_items => account.list_inactive_items,
                                       :active_items => account.list_active_items}
    end

    ##
    #  Shows your wishlist
    #
    #  Expects:
    #  session[:navigation] : has to be initialized
    #  session[:account] : your id as a user or organisation
    #
    ##
    get '/items/my/wishlist' do
      session[:navigation][:selected]  = "home"
      session[:navigation][:subnavigation] = "wishlist"

      account = Models::System.instance.fetch_account(session[:account])

      haml :'item/wish_list', :locals => {:wish_list_items => account.wish_list.items}
    end

    ##
    #  Shows the form for the item creation
    #
    #  Expects:
    #  session[:navigation] : has to be initialized
    #
    ##
    get '/item/create' do
       session[:navigation][:selected]  = "market"
       session[:navigation][:subnavigation] = "create item"

       haml :'item/create'
    end

    ##
    #
    #  Shows all active items in the market
    #
    #  Expects:
    #  session[:navigation] : has to be initialized
    #  session[:account] : your id as a user or organisation
    #
    ##
    get '/items/active' do
        session[:navigation][:selected] = "market"
        session[:navigation][:subnavigation] = "on sale"

        viewer_id = session[:account]
        haml :'item/active', :locals => {:all_items => DAOItem.instance.fetch_all_active_items_but_of(viewer_id)}
    end

    ##
    #
    #  Shows additional information on a specific item
    #
    #  Redirects:
    #  /item/active when you try to view an inactive item that's not yours
    #
    #  Expects:
    #  session[:account] : the owners id as a user or organisation
    #  params[:id] : id of the item
    #
    ##
    get '/item/:id' do
      redirect "/error/No_Valid_Item_Id" unless DAOItem.instance.item_exists?(params[:id])
      item = DAOItem.instance.fetch_item(params[:id])
      if !item.is_active? && item.owner.id != session[:account]
        session[:alert] = Alert.create("Inactive Item", "The Item you try to watch isn't active.", true)
        redirect "/items/active"
      end

      haml :'item/item', :locals => {:item => item}
    end

    ##
    #
    # Shows the form to write a comment on a specific item
    #
    # Expects:
    # params[:id] : the id of the item someone wants to comment on
    # TODO: I am not sure what this does, or if it is used
    ##
    get '/item/comment/:id' do
      item = DAOItem.instance.fetch_item(params[:id].to_i)
      haml :'item/comments', :locals => {:item => item }
    end

    ##
    #
    #  Shows the  make comment page, for a comment on a comment
    #
    #  Redirects:
    #  /error/No_Valid_Item_Id when the system doesn't know this item id
    #
    #  Expects:
    #  session[:navigation] : has to be initialized
    #  session[:account] : your id as a user or organisation
    #  params[:item_id] : the id of the item where you want to comment
    #  params[:comment_nr] : on which comment of this item you want to comment
    #
    ##
    get '/item/add/comment/:item_id/:comment_nr' do
      redirect "/error/No_Valid_Item_Id" unless DAOItem.instance.item_exists?(params[:item_id])

      item = DAOItem.instance.fetch_item(params[:item_id])

      haml :'item/comment', :locals => {:item => item, :comment_nr => params[:comment_nr]}
    end

    ##
    #
    #  Shows a page where a user/org. can set the expiration date on an item
    #
    #  Expects:
    #  params[:id] : the id of the item
    #
    ##
    get '/item/changestate/expiration' do
      item = DAOItem.instance.fetch_item(params[:id])

      haml :'item/expiration', :locals => {:item => item}
    end

    ##
    #
    #  Shows the form where a user/org. can edit the information
    #  on an item
    #
    #  Expects:
    #  params[:id] : the id of the item
    #
    ##
    get '/item/:id/edit' do
      before_for_item_manipulation

      id = params[:id]
      item = DAOItem.instance.fetch_item(params[:id])
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
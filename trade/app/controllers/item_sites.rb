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
        haml :'item/my_active', :locals => {:active_items => DAOItem.instance.fetch_active_items_of(user_id)}
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
        haml :'item/my_inactive', :locals => {:inactive_items => DAOItem.instance.fetch_inactive_items_of(user_id) }
    end

    get '/item/wish/list' do
        user_id = session[:account]
        haml :'item/wish_list', :locals => {:wish_list => DAOAccount.instance.fetch_account(user_id).wish_list}
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

      dao = DAOItem.instance

      haml :'item/my_all', :locals => {:inactive_items => dao.fetch_inactive_items_of(session[:account]),
                                       :active_items => dao.fetch_active_items_of(session[:account]) }
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

      account = DAOAccount.instance.fetch_account(session[:account])

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
      error_redirect("No valid Item ID", "The requested item id could not be found.", !DAOItem.instance.item_exists?(params[:id]), "/items/active")
      item = DAOItem.instance.fetch_item(params[:id])
      error_redirect("Inactive Item", "The Item you try to watch isn't active.", !item.is_active? && item.owner.id != session[:account], "/items/active")

      haml :'item/item', :locals => {:item => item}
    end

    ##
    #
    #  Shows the  make comment page, for a comment on a comment
    #
    #  Redirects:
    #  /items/active when the system doesn't know this item id
    #
    #  Expects:
    #  session[:navigation] : has to be initialized
    #  session[:account] : your id as a user or organisation
    #  params[:item_id] : the id of the item where you want to comment
    #  params[:comment_nr] : on which comment of this item you want to comment
    #
    ##
    get '/item/add/comment/:item_id/:comment_nr' do
      error_redirect("No valid Item ID", "The requested item id could not be found.", !DAOItem.instance.item_exists?(params[:item_id]), "/items/active")

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
      error_redirect("No valid Item ID", "The requested item id could not be found.", !DAOItem.instance.item_exists?(params[:id]), "/items/active")

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
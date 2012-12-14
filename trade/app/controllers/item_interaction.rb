##
#
# Here is everything concerning the interaction between items
# and users that are not necessary their owners. This means
# buy-requests, wishlist altering and comments on items.
#
##
module Controllers 
    class ItemInteraction < Sinatra::Application
        set :views, "#{absolute_path('../views', __FILE__)}"
        
        before do
          before_for_item_interaction
        end

        ###
        #
        #  This is called if a user or organisation tries to buy an item.
        #  After a successful buy the buyer will see all his items with the
        #  the new item added.
        #
        #  Redirects to:
        #  /item/:itemId when the price is greater than this accounts
        #                     credits, your org. limit, the item has been
        #                     modified or it is inactive
        #  /items/my/all when everthing is correct
        #
        #  Expects:
        #  params[:id] : id of the item
        #  params[:account] : the id of the buyer
        #  params[:user] :  the id of the seller
        #  params[:version] :  the version of the item that the buyer sees
        #
        ###
        post '/item/buy' do

          item = DAOItem.instance.fetch_item(params[:id])
          buyer = Models::System.instance.fetch_account(session[:account])
          user=Models::System.instance.fetch_account(session[:user])
          version = params[:version]

          unless item.can_be_bought_by?(buyer)
            session[:alert] = Alert.create("Oh no!", "You have not enough Credits to buy this Item.", true)
            redirect "/item/#{params[:id]}"
          end
          if  buyer!=user #true if it is a user acting as an organisation
            unless buyer.within_limit_of?(item, user)
              session[:alert] = Alert.create("Oh no!", "You tried to buy something for your organistion that is over your daily organisation limit.", true)
              redirect "/item/#{params[:id]}"
            end
          end

          unless item.current_version?(version)
            session[:alert] = Alert.create("Item has Changed!", "While you were watching this site, the Item was modified.", true)
            redirect "/item/#{item.id}"
          end
          buyer.buy_item(item, user)

          item.alter_version

          session[:alert] = Alert.create("Success!", "You bought #{item.name.create_link(item.id)}", false)
          redirect "/items/my/all"
        end

        ###
        #
        #  This adds an item to the wishlist of a user or organisation
        #
        #  Redirects to:
        #  back when it is know from where the user or org. came
        #  /items/active else
        #
        #  Expects:
        #  params[:id] : id of the item
        #  params[:account] : the id of the user or org.
        #
        ###
        post '/item/towishlist' do
          item = DAOItem.instance.fetch_item(params[:id])
          account = Models::System.instance.fetch_account(session[:account])

          #TODO check conditions!
          account.wish_list.add(item)
          session[:alert] = Alert.create("", "#{item.name.create_link(item.id)} has been added to your <a href=\"/items/my/wishlist\">wishlist</a>.", false)
          redirect back.nil? ? "/items/active" : back
        end

        ###
        #
        #  This removes an item from the wishlist of a user or organisation
        #
        #  Redirects to:
        #  back when it is know from where the user or org. came
        #  /items/my/all else
        #
        #  Expects:
        #  params[:id] : id of the item
        #  params[:account] : the id of the user or org.
        #
        ###
        post '/item/fromwishlist' do
          item = DAOItem.instance.fetch_item(params[:id])
          account = Models::System.instance.fetch_account(session[:account])

          #TODO check conditions!
          account.wish_list.remove(item)
          session[:alert] = Alert.create("", "#{item.name.create_link(item.id)} has been removed from your <a href=\"/items/my/wishlist\">wishlist</a>", false)
          redirect back.nil? ? "/items/my/all" : back
        end

        ###
        #
        #  With this a user or organisation can add a comment to an item
        #
        #  Redirects to:
        #  /error/No_Valid_Input when the comment is not empty and not nil
        #  /item/#{item.id} when everything is correct
        #
        #  Expects:
        #  params[:header] : the title of the comment
        #  params[:comment_nr] : important for the order of the comments
        #  params[:comment] : should not be nil and not empty
        #  params[:id] : id of the item
        #  params[:account] : the id of the user or org.
        #
        ###
        post '/item/add/comment/:id' do

          redirect "/error/No_Valid_Input" if params[:comment].nil? || params[:comment] == ""

          user = Models::System.instance.fetch_account(session[:account])
          item = DAOItem.instance.fetch_item(params[:id])

          comment = Comment.create(user, Sanitize.clean(params[:header]), Sanitize.clean(params[:comment]))
          if params[:comment_nr].nil?
            item.add(comment)
          else
            precomment = item.get(params[:comment_nr])
            precomment.add(comment)
          end

          redirect "/item/#{item.id}"
        end
    end
end

module Controllers 
    class ItemInteraction < Sinatra::Application
        set :views, "#{absolute_path('../views', __FILE__)}"
        
        before do
          before_for_item_interaction
        end


        post '/item/buy' do

          item = Models::System.instance.fetch_item(params[:id])
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

        post '/item/towishlist' do
          item = Models::System.instance.fetch_item(params[:id])
          account = Models::System.instance.fetch_account(session[:account])

          #TODO check conditions!
          account.wish_list.add(item)
          session[:alert] = Alert.create("", "#{item.name.create_link(item.id)} has been added to your Wish List", false)
          redirect back.nil? ? "/items/active" : back
        end

        post '/item/fromwishlist' do
          item = Models::System.instance.fetch_item(params[:id])
          account = Models::System.instance.fetch_account(session[:account])

          #TODO check conditions!
          account.wish_list.remove(item)
          session[:alert] = Alert.create("", "#{item.name.create_link(item.id)} has been removed from your wishlist", false)
          redirect back.nil? ? "/items/my/all" : back
        end

        post '/item/add/comment/:id' do

          redirect "/error/No_Valid_Input" if params[:comment].nil? || params[:comment] == ""

          user = Models::System.instance.fetch_account(session[:account])
          item = Models::System.instance.fetch_item(params[:id])

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
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

    get '/item/create' do
        haml :'item/create'
    end

    get '/item/auctionize' do
      haml :'item/auctionize'
    end

    get '/item/my/auctions' do
      haml :'item/my_auctions' , :locals => {:auctions => Models::System.instance.fetch_auctions_of(session[:account])}
    end

    get '/item/comment/:id' do
      item = System.instance.fetch_item(params[:id].to_i)
      haml :'item/comments', :locals => {:item => item }
    end

    get '/items/active' do
        viewer_id = session[:account]
        haml :'item/active', :locals => {:all_items => Models::System.instance.fetch_all_active_items_but_of(viewer_id)}
    end

    get '/items/all_auctions' do
      viewer_id = session[:account]
      haml :'item/all_auctions', :locals => {:auctions => Models::System.instance.fetch_all_auctions_but_of(viewer_id)}
    end

    get '/item/:id' do
      redirect "/error/No_Valid_Item_Id" unless Models::System.instance.item_exists?(params[:id])

      haml :'item/item', :locals => {:item => Models::System.instance.fetch_item(params[:id])}
    end

    get '/auction/:id' do
      redirect "/error/No_Valid_Auction_Id" unless Models::System.instance.auction_exists?(params[:id])
      haml :'item/auction', :locals => {:auction => Models::System.instance.fetch_auction(params[:id])}
    end

    get '/item/add/comment/:item_id/:comment_nr' do
      redirect "/error/No_Valid_Item_Id" unless Models::System.instance.item_exists?(params[:item_id])

      item = Models::System.instance.fetch_item(params[:item_id])

      haml :'item/comment', :locals => {:item => item, :comment_nr => params[:comment_nr]}
    end




  end
end
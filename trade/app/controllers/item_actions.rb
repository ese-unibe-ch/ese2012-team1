require 'rubygems'
require 'require_relative'
require 'sinatra/base'
require 'haml'
require 'sinatra/content_for'

require_relative('../models/user')
require_relative('../models/item')
require_relative('../models/comment')
require_relative('../models/auction')

require_relative('../helpers/render')
require_relative('../helpers/string_checkers')

include Models
include Helpers

module Controllers
  class ItemActions < Sinatra::Application
    set :views, "#{absolute_path('../views', __FILE__)}"

    before do
      redirect "/" unless session[:auth]
      response.headers['Cache-Control'] = 'public, max-age=0'
    end

    ##
    #
    # Creates an item
    #
    # Expects:
    # params[:name] : name for the item
    # params[:price] : price for the item
    # params[:description] :  description for the item
    # optional params[:item_picture] : picture for the item
    #
    ##

    post '/item/create' do
      redirect "/error/No_Name" if params[:name] == nil or params[:name].length == 0
      redirect "/error/No_Price" if params[:price] == nil
      redirect "/error/Not_A_Number" unless /^[\d]+(\.[\d]+){0,1}$/.match(params[:price])
      redirect "/error/No_Description" if params[:description] == nil
      redirect "/error/No_Valid_Account_Id" unless Models::System.instance.account_exists?(session[:account])

      fail "Item should have a name." if params[:name] == nil
      fail "Item name should not be empty" if params[:name].length == 0
      fail "Item should have a price" if params[:price] == nil
      fail "Price should be a number" unless /^[\d]+(\.[\d]+){0,1}$/.match(params[:price])
      fail "Item should have a description" if params[:description] == nil


      id = session[:account]
      new_item = Models::System.instance.fetch_account(id).create_item(params[:name], Integer((params[:price]).to_i))
      new_item.add_description(params[:description])

      dir = absolute_path('../public/images/items/', __FILE__)

      file_extension = ".png"
      fetch_file_path = absolute_path("../public/images/items/default_item.png", __FILE__)
      if params[:item_picture] != nil
        tempfile = params[:item_picture][:tempfile]
        filename = params[:item_picture][:filename]
        fetch_file_path = tempfile.path
        file_extension = File.extname(filename)
      end

      store_file_path ="#{dir}#{new_item.id}#{file_extension}"
      File.copy(fetch_file_path, store_file_path)

      new_item.add_picture("/images/items/#{new_item.id}#{file_extension}")

      puts("path: #{new_item.picture}")

      redirect "/items/my/inactive"
    end

    post '/item/auctionize' do
      redirect "/error/No_Name" if params[:name] == nil or params[:name].length == 0
      redirect "/error/No_Price" if params[:start_price] == nil
      redirect "/error/Not_A_Number" unless /^[\d]+(\.[\d]+){0,1}$/.match(params[:start_price])
      redirect "/error/No_Description" if params[:description] == nil
      redirect "/error/No_Increment" if params[:increment] == nil
      redirect "/error/Inc_Not_A_Number" unless /^[\d]+(\.[\d]+){0,1}$/.match(params[:increment])
      redirect "/error/No_Valid_Time" if Time.parse(params[:date_time]) < Time.now

      fail "Auction item should have a name." if params[:name] == nil
      fail "Auction item name should not be empty" if params[:name].length == 0
      fail "Auction item should have a start price" if params[:start_price] == nil
      fail "Price should be a number" unless /^[\d]+(\.[\d]+){0,1}$/.match(params[:start_price])
      fail "Auction item should have a description" if params[:description] == nil
      fail "Auction item should have an increment amount" if params[:increment] == nil
      fail "The end date should be in future" if Time.parse(params[:date_time]) < Time.now

      id = session[:account]
      new_item = Models::System.instance.fetch_account(id).create_item(params[:name], params[:start_price].to_i)
      new_item.add_description(params[:description])
      new_item.in_auction = true


      new_auction = Models::Auction.created(new_item, params[:start_price].to_i, params[:increment].to_i, params[:date_time])
      Models::System.instance.add_auction(new_auction)

      #----Picture upload
      dir = absolute_path('../public/images/items/', __FILE__)

      file_extension = ".png"
      fetch_file_path = absolute_path("../public/images/items/default_item.png", __FILE__)
      if params[:item_picture] != nil
        tempfile = params[:item_picture][:tempfile]
        filename = params[:item_picture][:filename]
        fetch_file_path = tempfile.path
        file_extension = File.extname(filename)
      end

      store_file_path ="#{dir}#{new_item.id}#{file_extension}"
      File.copy(fetch_file_path, store_file_path)

      new_item.add_picture("/images/items/#{new_item.id}#{file_extension}")

      puts("path: #{new_item.picture}")
      #------

      redirect "/items/my/auctions"
    end

    post '/item/changestate/setactive' do
      redirect "/error/No_Valid_Item_Id" unless Models::System.instance.item_exists?(params[:id])
      item = Models::System.instance.fetch_item(params[:id])

      if item.owner.id == session[:account]
        item.to_active
      end

      redirect "/items/my/inactive"
    end

    post '/item/changestate/setinactive' do
      redirect "/error/No_Valid_Item_Id" unless Models::System.instance.item_exists?(params[:id])
      item = Models::System.instance.fetch_item(params[:id])

      if item.owner.id == session[:account]
        item.to_inactive
      end

      redirect "/items/my/active"
    end

    post '/item/delete' do
      redirect "/error/No_Valid_Item_Id" unless Models::System.instance.item_exists?(params[:id])
      id = params[:id]
      Models::System.instance.fetch_item(id).clear
      redirect "/items/my/inactive"
    end

    post '/item/edit' do
      redirect "/error/No_Valid_Item_Id" unless Models::System.instance.item_exists?(params[:id])
      id = params[:id]
      name = Models::System.instance.fetch_item(id).name
      description = Models::System.instance.fetch_item(id).description
      price = Models::System.instance.fetch_item(id).price
      picture = Models::System.instance.fetch_item(id).picture
      haml :'item/edit', :locals => {:id => id, :name => name, :description => description, :price => price, :picture => picture}
    end

    post '/item/auction/edit' do
      redirect "/error/No_Valid_Auction_Id" unless Models::System.instance.auction_exists?(params[:id])
      id = params[:id]
      auction = Models::System.instance.fetch_auction(id)
      name = auction.item.name
      description = auction.item.description
      price = auction.price
      increment = auction.increment
      end_time = auction.end_time
      picture = auction.item.picture
      haml :'item/edit_auctionize', :locals => {:id => id, :name => name, :description => description, :price => price, :increment =>increment, :end_time => end_time, :picture => picture}
    end

    ###
    #
    #  Does edit an item.
    #  Needs params:
    #  :id : id of item to change
    #  :new_description : description to change
    #  :new_price : price to change
    #  :item_picture : picture to change
    #
    ###

    post '/item/edit/save' do
      redirect "/error/No_Valid_Item_Id" unless Models::System.instance.item_exists?(params[:id])
      id = params[:id]
      item=Models::System.instance.fetch_item(id)
      redirect "/items/my/inactive" if Models::System.instance.fetch_item(id).editable?
      new_description = params[:new_description]
      new_price = params[:new_price]
      item.add_description(new_description)
      item.price = new_price

      dir = absolute_path('../public/images/items/', __FILE__)

      if params[:item_picture] != nil
        tempfile = params[:item_picture][:tempfile]
        filename = params[:item_picture][:filename]
        file_path ="#{dir}#{id}#{File.extname(filename)}"
        File.copy(tempfile.path, file_path)
        file_path = "/images/items/#{id}#{File.extname(filename)}"
        item.add_picture(file_path)
      end

      redirect "/items/my/inactive"
    end

    post '/item/edit/save_auction' do
      auction = Models::System.instance.fetch_auction(params[:id])
      item = auction.item
      redirect "/error/No_Valid_Auction_Id" unless Models::System.instance.auction_exists?(params[:id])
      redirect "/error/No_Valid_Item_Id" unless Models::System.instance.item_exists?(item.id)
      redirect "/error/Auction_Has_Already_Been_Bidden" unless auction.no_bid_done_yet?

      new_description = params[:description]
      new_name = params[:name]
      item.add_description(new_description)
      item.add_name(new_name)

      new_price = params[:start_price]
      new_time = params[:date_time]
      auction.change_starting_price(new_price)
      auction.change_end_time(new_time)

      new_increment = params[:increment]
      auction.change_increment(new_increment)

      dir = absolute_path('../public/images/items/', __FILE__)

      if params[:item_picture] != nil
        tempfile = params[:item_picture][:tempfile]
        filename = params[:item_picture][:filename]
        file_path ="#{dir}#{id}#{File.extname(filename)}"
        File.copy(tempfile.path, file_path)
        file_path = "/images/items/#{id}#{File.extname(filename)}"
        item.add_picture(file_path)
      end

      redirect "/items/my/auctions"
    end


    post '/item/buy' do
      redirect "/error/No_Valid_Item_Id" unless Models::System.instance.item_exists?(params[:id])
      redirect "/error/No_Valid_Account_Id" unless Models::System.instance.account_exists?(session[:account])
      id = params[:id]
      item = Models::System.instance.fetch_item(id)
      user_id = session[:account]
      new_user = Models::System.instance.fetch_account(user_id)
      if item.can_be_bought_by?(new_user)
        new_user.buy_item(item)
        redirect "/items/my/inactive"
      else
        redirect "/error/Not_Enough_Credits"
      end
    end

    post '/auction/bid' do
      id = params[:id]
      max_bid = (params[:max_price]).to_i
      auction = Models::System.instance.fetch_auction(id)

      redirect "/error/Bid_Too_Small" unless (max_bid >= auction.price.last + auction.increment or (auction.bidder.last==nil and max_bid >= auction.price.last))
      redirect "/error/No_Valid_Item_Id" unless Models::System.instance.auction_exists?(id)
      redirect "/error/No_Valid_Account_Id" unless Models::System.instance.account_exists?(session[:account])
      #redirect "/error/Bid_Already_Exists" if auction.bid_exists?(max_bid)

      user_id = session[:account]
      new_user = Models::System.instance.fetch_account(user_id)
      if auction.can_be_bid_by?(new_user,max_bid) && !auction.bid_exists?(max_bid)
        auction.make_bet(new_user, max_bid)
        redirect "/auction/#{id}"
      else
        redirect "/error/Not_Enough_Credits_or_Bid_Exists"
      end
    end

    post '/item/add/comment/:id' do
      redirect "/error/No_Valid_Item_Id" unless Models::System.instance.item_exists?(params[:id])
      redirect "/error/No_Valid_Account_Id" unless Models::System.instance.account_exists?(session[:account])
      redirect "/error/No_Valid_Input" if params[:comment].nil? || params[:comment] == ""

      user = Models::System.instance.fetch_account(session[:account])
      item = Models::System.instance.fetch_item(params[:id])

      comment = Comment.create(user, params[:header], params[:comment])
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
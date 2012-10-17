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
  class ItemActions < Sinatra::Application
    set :views, "#{absolute_path('../views', __FILE__)}"

    set :raise_errors, false unless development?
    set :show_exceptions, false unless development?

    before do
      redirect "/" unless session[:auth]
    end

    ##
    #
    # Creates an item
    #
    # Expects a name for the item, a price and a description as parameters
    # Can also contain a picture.
    #
    ##

    post '/item/create' do
      redirect "/error/No_Name" if params[:name] == nil or params[:name].length == 0
      redirect "/error/No_Price" if params[:price] == nil
      redirect "/error/Not_A_Number" unless /^[\d]+(\.[\d]+){0,1}$/.match(params[:price])
      redirect "/error/No_Description" if params[:description] == nil
      redirect "/error/No_Valid_Account_Id" unless Models::System.instance.account_exists?(session[:account])

      fail "Item should have name." if params[:name] == nil
      fail "Item name should not be empty" if params[:name].length == 0
      fail "Item should have price" if params[:price] == nil
      fail "Price should be number" unless /^[\d]+(\.[\d]+){0,1}$/.match(params[:price])
      fail "Item should have description" if params[:description] == nil

      id = session[:account]
      new_item = Models::System.instance.fetch_account(id).create_item(params[:name], Integer((params[:price]).to_i))
      new_item.add_description(params[:description])

      dir = absolute_path('../public/images/items/', __FILE__)

      if params[:item_picture] != nil
        tempfile = params[:item_picture][:tempfile]
        filename = params[:item_picture][:filename]
        file_path ="#{dir}#{new_item.id}#{File.extname(filename)}"
        File.copy(tempfile.path, file_path)
        file_path = "/images/items/#{new_item.id}#{File.extname(filename)}"
        new_item.add_picture(file_path)
      end

      redirect "/items/my/inactive"
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
      haml :item_edit, :locals => {:id => id, :name => name, :description => description, :price => price, :picture => picture}
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

  end

  error do
    haml :error, :locals => {:error_title => "", :error_message => "#{request.env['sinatra.error'].to_s}" }
  end
end
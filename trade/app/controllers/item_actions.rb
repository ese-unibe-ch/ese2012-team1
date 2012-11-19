require 'rubygems'
require 'require_relative'
require 'sinatra/base'
require 'haml'
require 'sinatra/content_for'

require_relative('../models/user')
require_relative('../models/item')
require_relative('../models/comment')

require_relative('../helpers/render')
require_relative '../helpers/before'
require_relative('../helpers/string_checkers')
require_relative '../helpers/error_messages'

include Models
include Helpers

module Controllers
  class ItemActions < Sinatra::Application
    before do
      before_for_user_authenticated
    end

    set :views, "#{absolute_path('../views', __FILE__)}"

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
      @error[:name] = ErrorMessages.get("No_Name") if params[:name] == nil || params[:name].length == 0
      @error[:price] =  ErrorMessages.get("Not_A_Number") unless /^[\d]+(\.[\d]+){0,1}$/.match(params[:price])
      @error[:price] = ErrorMessages.get("No_Price") if params[:price] == nil || params[:price].length == 0
      @error[:description] = ErrorMessages.get("No_Description") if params[:description] == nil || params[:description].length == 0

      unless (@error.empty?)
        halt haml :'/item/create'
      end

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

      session[:navigation].get_selected.select("home")
      session[:navigation].get_selected.subnavigation.select("items")

      session[:alert] = Alert.create("Success!", "You created a new item: #{create_link(new_item)}", false)
      redirect "/items/my/all"
    end

    post '/item/changestate/setactive' do
      redirect "/error/No_Valid_Item_Id" unless Models::System.instance.item_exists?(params[:id])
      item = Models::System.instance.fetch_item(params[:id])

      if item.owner.id == session[:account]
        item.to_active
      end

      session[:alert] = Alert.create("Success!", "You created have activated #{create_link(item)}", false)
      redirect "/items/my/all"
    end

    def create_link(item)
      "<a href=\'/item/#{item.id}\'>#{item.name}</a>"
    end

    post '/item/changestate/setinactive' do
      redirect "/error/No_Valid_Item_Id" unless Models::System.instance.item_exists?(params[:id])
      item = Models::System.instance.fetch_item(params[:id])

      if item.owner.id == session[:account]
        item.to_inactive
      end

      session[:alert] = Alert.create("Success!", "You have deactivated #{create_link(item)}", false)
      redirect "/items/my/all"
    end

    post '/item/delete' do
      redirect "/error/No_Valid_Item_Id" unless Models::System.instance.item_exists?(params[:id])
      id = params[:id]
      Models::System.instance.fetch_item(id).clear

      session[:alert] = Alert.create("Success!", "You created have deleted item: #{item.name}", false)
      redirect "/items/my/all"
    end

    get '/item/edit' do
      redirect '/'
    end

    post '/item/edit' do
      id = params[:id]
      redirect "/error/No_Valid_Item_Id" unless Models::System.instance.item_exists?(params[:id])
      name = Models::System.instance.fetch_item(id).name
      description = Models::System.instance.fetch_item(id).description
      description_list = Models::System.instance.fetch_item(id).description_list
      description_position = Models::System.instance.fetch_item(id).description_position
      price = Models::System.instance.fetch_item(id).price
      picture = Models::System.instance.fetch_item(id).picture
      haml :'item/edit', :locals => {:id => id, :name => name, :description => description, :description_list => description_list, :description_position => description_position, :price => price, :picture => picture}
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
      redirect "/error/No_Price" if params[:new_price] == nil
      redirect "/error/Not_A_Number" unless /^[\d]+(\.[\d]+){0,1}$/.match(params[:new_price])
      new_price = params[:new_price].to_i
      item.add_description(new_description) if item.description != new_description
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

    ##
    #  Save the current description which should be displayed
    #
    ##
    post '/item/edit/save_description' do
      redirect "/error/No_Valid_Item_Id" unless Models::System.instance.item_exists?(params[:id])

      id = params[:id]
      desc_to_use = params[:desc_to_use].to_i
      item = Models::System.instance.fetch_item(id)
      item.description_position = desc_to_use

      haml :'item/save_description_success', :locals => {:id => id}
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
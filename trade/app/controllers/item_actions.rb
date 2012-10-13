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
  class ItemActions < Sinatra::Application
    set :views , "#{absolute_path('../views', __FILE__)}"

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

    post '/create' do
        fail "Should have name." if params[:name] == nil
        fail "Should have price" if params[:price] == nil
        fail "Should have description" if params[:description] == nil
        fail "Should be number" unless /^[\d]+(\.[\d]+){0,1}$/.match(params[:price])

        user = session[:user]

          new_item = User.get_user(user).create_item(params[:name], Integer((params[:price]).to_i))
          new_item.add_description(params[:description])

          dir = absolute_path('../public/images/items/', __FILE__)

          if params[:item_picture] != nil
            tempfile = params[:item_picture][:tempfile]
            filename = params[:item_picture][:filename]
            file_path ="#{dir}#{new_item.get_id}#{File.extname(filename)}"
            File.copy(tempfile.path, file_path)
            file_path = "../images/items/#{new_item.get_id}#{File.extname(filename)}"
            new_item.add_picture(file_path)
          end

        redirect "/home/inactive"
    end

    post '/changestate/setactive' do
        item = Item.get_item(params[:id])
        if item.owner.name == session[:user]
          item.to_active
        end
        redirect "/home/inactive"
    end

    post '/changestate/setinactive' do
      item = Item.get_item(params[:id])
      if item.owner.name == session[:user]
        item.to_inactive
      end
      redirect "/home/active"
    end

    post '/home/delete' do
      id = params[:id]
      Item.get_item(id).clear
      redirect "/home/inactive"
    end

    post '/home/edit' do
      id = params[:id]
      name = Item.get_item(id).name
      description = Item.get_item(id).description
      price = Item.get_item(id).price
      picture = Item.get_item(id).picture
      haml :home_edit , :locals => {:id => id, :name => name, :description => description, :price => price, :picture => picture}
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

    post '/home/edit/save' do
      id = params[:id]
      redirect "/home/inactive" if Item.get_item(id).editable?
      new_description = params[:new_description]
      new_price = params[:new_price]
      Item.get_item(id).add_description(new_description)
      Item.get_item(id).price = new_price

      dir = absolute_path('../public/images/items/', __FILE__)

      if params[:item_picture] != nil
        tempfile = params[:item_picture][:tempfile]
        filename = params[:item_picture][:filename]
        file_path ="#{dir}#{id}#{File.extname(filename)}"
        File.copy(tempfile.path, file_path)
        file_path = "../images/items/#{id}#{File.extname(filename)}"
        Item.get_item(id).add_picture(file_path)
      end

      redirect "/home/inactive"
    end

    post '/buy' do
        id = params[:id]
        item = Item.get_item(id)
        old_user = item.get_owner
        user = session[:user]
        new_user = User.get_user(user)
        if new_user.buy_new_item?(item)
          old_user.remove_item(item)
        else
          redirect "/error/Not_Enough_Credits"
        end
        redirect "/home/inactive"
    end

  end
end
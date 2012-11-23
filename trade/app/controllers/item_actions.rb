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
    set :views, "#{absolute_path('../views', __FILE__)}"

    before do
      before_for_user_authenticated
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

      session[:alert] = Alert.create("Success!", "You created a new item: #{new_item.name.create_link(new_item.nr)}", false)
      redirect "/items/my/all"
    end
  end
end
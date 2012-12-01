require_relative '../helpers/HTML_constructor'

module Controllers

  ##
  #
  #  Item has to be passed via params[:id]
  #  if not then #before_for_item_manipulation
  #  will fail.
  #
  ##

  class ItemManipulation < Sinatra::Application
    set :views, "#{absolute_path('../views', __FILE__)}"

    before do
      before_for_item_manipulation
    end

    ##
    #
    # Sets the state of item to active
    # and sets a success success message
    #
    # Redirects to:
    # /items/my/all
    #
    # Expects:
    # params[:id]: id of the item
    #
    ##

    post '/item/changestate/setactive' do
      item = Models::System.instance.fetch_item(params[:id])

      item.to_active

      if(params[:date])
        #TODO: Use real date instead!
        item.add_expiration_date(Time.now + params[:date].to_i)
      end

      session[:alert] = Alert.create("Success!", "You put #{item.name.create_link(item.id)} on market", false)
      redirect "/items/my/all"
    end

    ##
    #
    # Sets the state of item to inactive
    # and sets a success message
    #
    # Redirects to:
    # /items/my/all
    #
    # Expects:
    # params[:id]: id of the item
    #
    ##

    post '/item/changestate/setinactive' do
      item = Models::System.instance.fetch_item(params[:id])

      item.to_inactive

      session[:alert] = Alert.create("Success!", "You have #{item.name.create_link(item.id)} removed from market", false)
      redirect "/items/my/all"
    end

    ##
    #
    # Deletes an item from the system
    # and sets a success message
    #
    # Expects:
    # params[:id]: id of the item
    #
    ##

    post '/item/delete' do
      item = Models::System.instance.fetch_item(params[:id])
      item.clear

      session[:alert] = Alert.create("Success!", "You have deleted item: #{item.name}", false)
      redirect "/items/my/all"
    end

    get '/item/edit' do
      redirect '/'
    end

    post '/item/edit' do
      id = params[:id]
      item = Models::System.instance.fetch_item(params[:id])
      name = item.name
      description = item.description
      description_list = item.description_list
      description_position = item.description_position
      price = item.price
      picture = item.picture

      haml :'item/edit', :locals => {:id => id, :name => name, :description => description, :description_list => description_list, :description_position => description_position, :price => price, :picture => picture}
    end

    ###
    #
    #  Does edit an item.
    #
    #  Redirects to:
    # /items/my/all without change when item is not editable
    # /error/No_Price when no price is set
    # /error/Not_A_Number when price is not a number
    # /items/my/all with all changes when everything is okay
    #
    #  Expects:
    #  params[:id] : id of item to change
    #  params[:new_description] : description to change
    #  params[:new_price] : price to change
    #  params[:item_picture] : picture to change
    #
    ###

    post '/item/edit/save' do
      item = Models::System.instance.fetch_item(params[:id])

      redirect "/items/my/all" unless item.editable?

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
        file_path ="#{dir}#{params[:id]}#{File.extname(filename)}"
        File.copy(tempfile.path, file_path)
        file_path = "/images/items/#{params[:id]}#{File.extname(filename)}"
        item.add_picture(file_path)
      end

      redirect "/items/my/all"
    end

    ##
    #  Save the current description which should be displayed
    #
    ##

    post '/item/edit/save_description' do

      desc_to_use = params[:desc_to_use].to_i
      id = params[:id] .to_i
      item = Models::System.instance.fetch_item(id)
      item.description_position = desc_to_use

      haml :'item/save_description_success', :locals => {:id => id}
    end
  end
end
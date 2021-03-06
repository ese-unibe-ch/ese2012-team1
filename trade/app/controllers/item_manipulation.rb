include Models
include Helpers

module Controllers

  ##
  #
  #  In this controller all changes a user can make on his own
  #  items are handled.
  #
  #  Item has to be passed via params[:id]
  #  if not then #before_for_item_manipulation
  #  will fail.
  #
  ##

  class ItemManipulation < Sinatra::Application
    set :views, "#{absolute_path('../views', __FILE__)}"

    ##
    #
    # Sets the state of item to active
    # and sets a success success message
    #
    # Redirects to:
    # /item/expiration if params[:date] is not a date or not in future
    # /items/my/all
    #
    # Expects:
    # params[:id]: id of the item
    # optional params[:date]: date when the selling expires
    #
    ##

    post '/item/changestate/setactive' do
      before_for_item_manipulation

      item = DAOItem.instance.fetch_item(params[:id])

      if(params[:date] != ""  && !params[:date].nil?)

        unless (params[:date] =~ /^\d\d\.\d\d\.\d\d\d\d\s\d\d:\d\d$/)
          @error[:date] = "Date has not correct format. Should be \'dd.mm.yyyy hh:mm\'"
          redirect "/item/expiration"
        end

        date_and_time = params[:date].split(/\s/)
        time = date_and_time[1]
        date = date_and_time[0]
        day_month_year = date.split(/\./)
        hours_minutes = time.split(":")

        unless(Date.valid_date?(day_month_year[2].to_i, day_month_year[1].to_i, day_month_year[0].to_i))
          @error[:date] = "You entered a invalid date"
          redirect "/item/expiration"
        end

        unless(time =~ /^([01]?[0-9]|2[0-3])\:[0-5][0-9]$/)
          @error[:date] = "You entered an invalid time"
          redirect "/item/expiration"
        end

        time = Time.local(day_month_year[2].to_i, day_month_year[1].to_i, day_month_year[0].to_i, hours_minutes[0], hours_minutes[1])

        error_redirect("", "You can't set time in past.", time <= Time.now, "/item/changestate/expiration?id=" + item.id.to_s)

        item.add_expiration_date(time)
      end

      item.to_active
      item.alter_version

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
      before_for_item_manipulation

      item = DAOItem.instance.fetch_item(params[:id])

      item.to_inactive
      item.alter_version

      session[:alert] = Alert.create("Success!", "You have #{item.name.create_link(item.id)} removed from market", false)
      redirect back.nil? ? "/items/my/all" : back
    end

    ##
    #
    # Deletes an item from the system
    # and sets a success message
    #
    # Redirects:
    # /items/my/all
    #
    # Expects:
    # params[:id]: id of the item
    #
    ##

    post '/item/delete' do
      before_for_item_manipulation

      item = DAOItem.instance.fetch_item(params[:id])
      item.clear

      session[:alert] = Alert.create("Success!", "You have deleted item: #{item.name}", false)
      redirect "/items/my/all"
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
      before_for_item_manipulation

      item = DAOItem.instance.fetch_item(params[:id])

      redirect "/items/my/all" unless item.editable?

      new_description = Sanitize.clean(params[:new_description])

      error_redirect("No Price set", "You have to set a Price for this Item.", params[:new_price] == nil || params[:new_price].length == 0, "/item/#{params[:id]}/edit")
      error_redirect("Not a Number", "Price should be a number!", !/^[\d]+(\.[\d]+){0,1}$/.match(params[:new_price]), "/item/#{params[:id]}/edit")

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

      item.alter_version

      redirect "/items/my/all"
    end

    ##
    #  Save the current description which should be displayed
    #
    #  Redirects:
    #  /items/my/all
    #
    #  Expects:
    #  params[:desc_to_use] : the new description
    #  params[:id] : id of the item
    #
    ##

    post '/item/edit/save_description' do
      before_for_item_manipulation

      desc_to_use = params[:desc_to_use].to_i
      id = params[:id] .to_i
      item = DAOItem.instance.fetch_item(id)
      item.description_position = desc_to_use

      item.alter_version

      session[:alert] = Alert.create("Success!", "You have reset description of #{item.name}", false)
      redirect "/items/my/all"
    end
  end
end
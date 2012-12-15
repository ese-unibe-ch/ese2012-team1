include Models
include Helpers

##
# In this controller is handled how an item is created
##
module Controllers
  class ItemCreate < Sinatra::Application
    set :views, "#{absolute_path('../views', __FILE__)}"

    ##
    #
    # Creates an item an redirects to
    # /items/my/all and setting an success
    # alert.
    #
    # Returns to /item/create with error alert
    # if there are some input errors.
    #
    #
    # Expects:
    # session[:account] : the account id on which behalf this user is acting now
    # params[:name] : name for the item
    # params[:price] : price for the item
    # params[:description] :  description for the item
    # TODO: Description should be optional?
    # optional params[:item_picture] : picture for the item
    #
    ##

    post '/item/create' do
      before_for_user_authenticated

      @error[:name] = ErrorMessages.get("No_Name") if params[:name] == nil || params[:name].length == 0
      @error[:price] =  ErrorMessages.get("Not_A_Number") unless /^[\d]+(\.[\d]+){0,1}$/.match(params[:price])
      @error[:price] = ErrorMessages.get("No_Price") if params[:price] == nil || params[:price].length == 0
      @error[:description] = ErrorMessages.get("No_Description") if params[:description] == nil || params[:description].length == 0

      unless @error.empty?
        halt haml :'/item/create'
      end

      id = session[:account]
      new_item = DAOAccount.instance.fetch_account(id).create_item(Sanitize.clean(params[:name]), Integer((params[:price]).to_i))
      new_item.add_description(Sanitize.clean(params[:description]))

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

      session[:navigation][:selected]  = "home"
      session[:navigation][:subnavigation]  = "items"

      session[:alert] = Alert.create("Success!", "You created a new item: #{new_item.name.create_link(new_item.id)}", false)
      redirect "/items/my/all"
    end
  end
end
require 'rubygems'
require 'require_relative'
require 'sinatra/base'
require 'haml'
require 'sinatra/content_for'
require_relative('../models/user')
require_relative('../models/item')
require_relative('../helpers/render')
require_relative '../helpers/before'

include Models
include Helpers

module Controllers
  class Error < Sinatra::Application
    before do
      before_for_user_not_authenticated
    end

    set :views , "#{absolute_path('../views', __FILE__)}"

    get '/error/:title' do
        title = params[:title]
        msg = ""
        if params[:title] == "Not_A_Number"
          msg = "Price should be a number!"
        elsif params[:title] == "Not_Enough_Credits"
          msg = "Sorry, but you can't buy this item, because you have not enough credits!"
        elsif params[:title] == "No_Valid_Account_Id"
          msg = "Your account id could not be found"
        elsif params[:title] == "No_Valid_User"
          msg = "Your email could not be found"
        elsif params[:title] == "No_Name"
          msg = "Please enter a name"
        elsif params[:title] == "No_Description"
          msg = "Please enter a description"
        elsif params[:title] == "No_Valid_Item_Id"
          msg = "The requested item id could not be found"
        elsif params[:title] == "Choose_Another_Name"
          msg = "The name you chose is already taken, choose another one"
        elsif params[:title] == "No_Self_Right_Revoke"
          msg = "You can not revoke administrator privileges from yourself if you are the only Administrator of an Organisation."
        elsif params[:title] == "Wrong_Activation_Code"
          msg = "The activation code in the URL is not correct.<br />Try with copy and paste the complete URL from the e-mail into your Browser."
        elsif params[:title] == "Already_Activated"
          msg = "You've already activated your User Account.<br /><a href=\"/login\" >Go To Login Page</a>"
        elsif params[:title] == "Not_an_Admin"
          msg = "You're not an administrator of this Organisation"
        elsif params[:title] == "Is_already_Admin"
          msg = "This user is already an Administrator of this Organisation"
        elsif params[:title] == "Yor_Are_Only_Admin"
          msg = "You are the only administrator in one of your Organisations.<br />You should provide Admin privileges to one of your Members or delete the Organisation first."
        elsif params[:title] == "Not_In_Organisation_View"
          msg = "You can't leave an organisation when you're not in your Organisations Profile."
        elsif params[:title] == "No_Self_Remove"
          msg = "You can't leave this Organisation, because you're the only Administrator."
        elsif params[:title] == "Try_Remove_Other"
          msg = "You're trying to remove an other User from the Organisation.<br />You're only permitted to remove yourself."
        elsif params[:title] == "Over_Your_Organisation_Limit"
          msg = "You tried to buy something for your organistion that is over your daily organisation limit."
        elsif params[:title] == "Wrong_Limit"
          msg = "You should enter an Integer Value bigger than 0 to set a Limit.<br />Leave field Empty to remove the Limit."
        else
          title = "Not_An_Error"
          msg = "This is a wrong Error Code."
        end
        title = title.gsub("_", " ")
        haml :error, :locals => {:error_title => title, :error_message => msg}
    end
  end
end
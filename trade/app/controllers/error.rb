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
  class Error < Sinatra::Application
    set :views , "#{absolute_path('../views', __FILE__)}"

    before do
      #redirect "/" unless session[:auth]
      response.headers['Cache-Control'] = 'public, max-age=0'
    end

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
        elsif params[:title] == "No_Self_Remove"
          msg = "You can not remove yourself from your organisation"
        elsif params[:title] == "Wrong_Activation_Code"
          msg = "The activation code in the URL is not correct.<br />Try with copy and paste the complete URL from the e-mail into your Browser."
        elsif params[:title] == "Already_Activated"
          msg = "You've already activated your User Account.<br /><a href=\"/login\" >Go To Login Page</a>"
        else
          title = "Not_An_Error"
          msg = "This is a wrong Error Code."
        end
        haml :error, :locals => {:error_title => title, :error_message => msg}
    end
  end
end
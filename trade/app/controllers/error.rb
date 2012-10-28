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
      redirect "/" unless session[:auth]
      response.headers['Cache-Control'] = 'public, max-age=0'
    end

    get '/error/:title' do
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
        else
          redirect '/home'
        end
        haml :error, :locals => {:error_title => params[:title], :error_message => msg}
    end
  end
end
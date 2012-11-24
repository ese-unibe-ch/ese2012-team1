##
#
# Requires concerning the model
#
##

require 'rubygems'
require 'bcrypt'
require 'sinatra'
require 'rack/protection'
require 'haml'
require 'haml/template/options'
require 'require_relative'

require_relative 'models/search/search'
require_relative 'models/search/search_item'
require_relative 'models/search/search_result'
require_relative('models/search/search_item_organisation')
require_relative 'models/search/search_item_item'
require_relative('models/search/search_item_user')

require_relative 'models/comment_container'
require_relative 'models/comment'
require_relative('models/item')
require_relative('models/account')
require_relative('models/system')
require_relative('models/organisation')
require_relative 'models/reversable_description'

require_relative('helpers/render')
require_relative('helpers/string_checkers')
require_relative('helpers/navigation')
require_relative('helpers/navigations')
require_relative('helpers/mailer')
require_relative('helpers/HTML_constructor')

require_relative('controllers/home')
require_relative('controllers/authentication')
require_relative('controllers/organisation_admin')
require_relative('controllers/registration')
require_relative('controllers/item_actions')
require_relative('controllers/item_sites')
require_relative('controllers/user_sites')
require_relative('controllers/organisation')
require_relative('controllers/account_edit')
require_relative('controllers/item_manipulation')
require_relative('controllers/error')
require_relative('controllers/search')

require_relative('init.rb') unless ENV['RACK_ENV'] == 'test'

include Helpers
include Models
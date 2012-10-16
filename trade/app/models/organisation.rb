require 'rubygems'
require 'require_relative'

require_relative('account')
require_relative('system')

module Models
 class Organisation < Models::Account
    #An Organisation is an account which is accessed by multiple users.
    #every user in the users list can act as the organisation and buy or sell items for it
    #Accounts have a name, an amount of credits, a description, an avatar and a list of users.
    #organisations may own certain items
    #organisations (represented by the users in the list) may buy and sell  items of another user or organisation

    # generate getter and setter
    attr_accessor :users

    def initialize
      super
      self.users = Hash.new
    end

    def add_member(user)
      self.users.store(user.email, user)
    end

    def is_member?(user)
      users.one? { |email, member| email == user.email }
    end
  end
end
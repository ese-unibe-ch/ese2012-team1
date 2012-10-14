require 'rubygems'
require 'require_relative'

require_relative 'item'
require_relative '../helpers/render'

include Helpers

module Models

  class Account
    #Account is an abstract class. It's designed to simplify the behaviour of the shop.
    #Accounts have a name, an amount of credits, a description and an avatar.
    #Implementations of accounts may add a new item to the system with a name and a price;
    #  the item is originally inactive.
    #Implementations of accounts may own certain items
    #Implementations of accounts may buy active items of another user
    #  (inactive items can't be bought). If an implementation of account buys an item,
    #  it becomes the owner; credits are transferred accordingly; immediately after
    #  the trade, the item is inactive. The transaction
    #  fails if the buyer has not enough credits.

    # generate getter and setter
    attr_accessor :description, :avatar, :name, :credits, :id


    ###
    #
    # At the start an account owns 100 credits
    #
    ##

    def initialize
      self.credits = 100
    end

    def self.created(name, description, avatar)
      fail "Missing name" if (name == nil)
      fail "Missing description" if (description == nil)
      fail "Missing path to avatar" if (avatar == nil)
      fail "There's no avatar at #{avatar}" unless (File.exists?(absolute_path(avatar.sub("images", "public/images"), __FILE__)))

      account = self.new
      account.name = name
      account.description = description
      account.avatar = avatar

      account.save

      account
    end

    def save
      fail("Template method to be implemented by subclass")
    end

    #get string representation
    def to_s
      "#{self.name} has currently #{self.credits} credits"
    end

    #let the account create a new item and returns it
    def create_item(name, price)
      fail "No name set" if (name == nil)
      fail "No price set" if (price == nil)
      fail "Price has to be positive" if (price < 0)

      new_item = Models::Item.created(name, price, self)
      Models::System.instance.add_item(new_item)

      new_item
    end

    # buy an item
    # @return true if user can buy item, false if his credit amount is to small
    # Removes the price of the item from itself and give it to the owner
    def buy_item(item_to_buy)
      fail "not enough credits" if item_to_buy.price > self.credits
      fail "Item not in System" unless (System.instance.items.include?(item_to_buy.id))
      # PZ: Don't like that I can't do that:
      # fail "Item already belongs to you" if (System.instance.fetch_items_of(self.id))

      old_owner = item_to_buy.owner
      #Subtracts price from buyer
      self.credits = self.credits - item_to_buy.price
      #Adds price to owner
      old_owner.credits += item_to_buy.price

      item_to_buy.bought_by(self)
    end


    #Removes himself from the list of users and of the system
    #Removes users items before
=begin
    def clear
      fail "not implemented"
      System.items.delete(System.get_my_items(self))
      Systems.users.delete(self.name)
    end
=end

  end
end
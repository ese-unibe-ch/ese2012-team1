require 'rubygems'
require 'require_relative'
require_relative '../helpers/render'

module Models

  class Account
    #Account is a abstract class. It's designed to simplify the behave of the shop.
    #Accounts have a name, an amount of credits, a description and a avatar.
    #Implementations of accounts may add a new item to the system with a name and a price;
    #  the item is originally inactive.
    #Implementations of accounts may own certain items
    #Implementations of accounts may buy active items of another user
    #  (inactive items can't be bought). When a implementation of account buys an item,
    #  it becomes the owner; credit are transferred accordingly; immediately after
    #  the trade, the item is inactive. The transaction
    #  fails if the buyer has not enough credits.

    # generate getter and setter
    attr_accessor :description, :avatar, :name, :credits


    #get string representation
    def to_s
      "#{self.name} has currently #{self.credits} credits"
    end

    #let the account create a new item
    def create_item(name, price)
      new_item = Models::Item.created(name, price, self)
      System.item_list.push(new_item)
    end

    # buy an item
    # @return true if user can buy item, false if his credit amount is to small
    def buy_item(item_to_buy)
      fail "not enough credits" if item_to_buy.get_price > self.credits
      fail "not adapted to System-Model"
      self.credits = self.credits - item_to_buy.get_price
      item_to_buy.to_inactive
      item_to_buy.set_owner(self)
      self.item_list.push(item_to_buy)
    end

    #Removes himself from the list of users and of the system
    #Removes users items before
    def clear
      fail "not implemented"
      System.items.delete(System.get_my_items(self))
      Systems.users.delete(self.name)
    end

  end
end
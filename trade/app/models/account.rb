module Models
  class Account
    ##
    #
    #Account is an abstract class. It's designed to simplify the behaviour of the shop.
    #Accounts have a name, an amount of credits, a description and an avatar.
    #Implementations of accounts may add a new item to the system with a name and a price;
    #  the item is originally inactive.
    #Implementations of accounts may own certain items
    #Implementations of accounts may buy active items of another account
    #  (inactive items can't be bought). If an implementation of account buys an item,
    #  it becomes the owner; credits are transferred accordingly; immediately after
    #  the trade, the item is inactive. The transaction
    #  fails if the buyer has not enough credits.
    #
    # generate getter and setter
    #
    ##
    attr_accessor :description, :avatar, :name, :credits, :id, :organisation, :wish_list


    ###
    #
    # At the start an account owns 100 credits
    #
    ##

    def initialize
      self.credits = 100
    end

    ##
    #
    # Creates a new account
    #
    # Expected:
    # name : name of the account(can't be nil)
    # description : description of the account (can't be nil)
    # avatar : Avatar of the account (can't be nil)
    #
    ##
    def self.created(name, description, avatar)
      fail "Missing name" if (name == nil)
      fail "Missing description" if (description == nil)
      fail "Missing path to avatar" if (avatar == nil)
      fail "There's no avatar at #{avatar}" unless (File.exists?(absolute_path(avatar.sub("/images", "../public/images"), __FILE__)))

      account = self.new
      account.id = nil
      account.name = name
      account.description = description
      account.avatar = avatar
      account.organisation = false
      account.wish_list = WishList.new

      account.save

      account
    end

    ##
    #
    # Adds the account to the system database
    #
    ##
    def save
      DAOAccount.instance.add_account(self)
    end

    ##
    #
    # get string representation
    #
    ##
    def to_s
      "#{self.name}:#{self.id}"
    end

    ##
    #
    # lets the account create a new item with this account as owner and returns it
    #
    # Expected:
    # name : the name of the new item(can't be nil)
    # price : the price of the new item(can't be nil or < 0)
    #
    ##
    def create_item(name, price)
      fail "No name set" if (name == nil)
      fail "No price set" if (price == nil)
      fail "Price has to be positive" if (price < 0)

      new_item = Models::Item.created(name, price, self)
      DAOItem.instance.add_item(new_item)

      new_item
    end

    ##
    #
    # Removes credits (price of item) from itself and gives it to the owner.
    # The item will switch owners. The buyer needs to have enough credits
    #
    # Expected:
    # item_to_buy : the item that user wants to buy
    # user : the account who pays credits and will be the new owner
    #
    ##
    def buy_item(item_to_buy, user)
      fail "not enough credits" if item_to_buy.price > self.credits
      fail "Item not in System" unless (DAOItem.instance.item_exists?(item_to_buy.id))

      old_owner = item_to_buy.owner

      #Subtracts price from buyer
      self.credits = self.credits - item_to_buy.price
      #Adds price to owner
      old_owner.credits += item_to_buy.price

      item_to_buy.bought_by(self)
    end

    ##
    #
    # Needs to be overridden in classes that inherit from account.rb
    #
    ##
    def is_member?(user)
      false
    end

    ##
    #
    # returns account's item list
    #
    ##
    def list_items
      DAOItem.instance.fetch_items_of(self.id)
    end

    ##
    #
    # returns account's list of inactive items
    #
    ##
    def list_inactive_items
      DAOItem.instance.fetch_items_of(self.id).select {|s| !s.is_active?}
    end


    ##
    #
    # returns account's list of active items
    #
    ##
    def list_active_items
      DAOItem.instance.fetch_items_of(self.id).select {|s| s.is_active?}
    end

    ##
    #
    # Returns true if an user owns a specific item
    #
    # Expects:
    # itemId : the id of the item you want to check
    #
    ##
    def has_item?(itemId)
      DAOItem.instance.item_exists?(self.id) &&
      DAOItem.instance.fetch_item(self.id).owner == self
    end

    ##
    #
    # Returns item with the given id. Throws error if
    # user doesn't own the item.
    #
    # Expects:
    # item_Id : the id of the item
    #
    ##
    def get_item(item_Id)
      fail "#{self.name} doesn't own object: \'#{item_Id}\'" unless (self.has_item?(item_Id.to_i))

      DAOItem.instance.fetch_item(item_Id)
    end
  end
end
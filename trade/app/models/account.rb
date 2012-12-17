module Models
  ##
  #
  # Account is an abstract class. It's designed to simplify the behaviour of the shop.
  #
  # Accounts have
  # * name
  # * amount of credits : set by default to 100
  # * description
  # * avatar.
  #
  # An Implementation of Account may
  # * add a new item to the system with a name and a price the item is originally inactive.
  # * own certain items
  # * buy active items of another account (inactive items can't be bought).
  #
  # If an implementation of account buys an item, it becomes the owner; credits are
  # transferred accordingly; immediately after the trade, the item is inactive.
  # The transaction fails if the buyer has not enough credits.
  #
  # Generates getter and setter
  #
  ##
  class Account
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
    # <b>Parameters</b>
    #
    # [name] name of the account(can't be nil)
    # [description] description of the account (can't be nil)
    # [avatar] Path to avatar of the account (can't be nil and file must already exist when added)
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
    # Returns string representation
    #
    ##
    def to_s
      "#{self.name}:#{self.id}"
    end

    ##
    #
    # Creates a new item with this account as owner and returns it
    #
    # <b>Parameters:</b>
    #
    # [name] the name of the new item (can't be nil)
    # [price] the price of the new item (can't be nil and must be greater or equal to 0)
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
    # Removes credits (price of item) from itself and gives it to the old
    # owner of the item. The item will switch owners. The buyer needs to
    # have enough credits
    #
    # <b>Parameters</b>
    #
    # [item_to_buy] the item that user wants to buy (Can't be nil and must be registered in Database)
    # [user] the account who pays credits and will be the new owner (Must have credits greater or equal than price of item)
    #
    ##
    def buy_item(item_to_buy, user)
      fail "missing item" if item_to_buy.nil?
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
    # Checks if the given user is a member of this account.
    #
    # Can be overridden in classes that inherit from account.rb
    # (see Organisation)
    #
    # <b>Parameters</b>
    #
    # [user] user to be checked
    #
    ##
    def is_member?(user)
      false
    end

    ##
    #
    # Returns true if an user owns a specific item
    # Returns false otherwise.
    #
    # <b>Parameters</b>
    #
    # [item_id] : the id of the item you want to check
    #
    ##
    def has_item?(item_id)
      DAOItem.instance.item_exists?(item_id) &&
      DAOItem.instance.fetch_item(item_id).owner == self
    end

    ##
    #
    # Returns item with the given id. Throws error if
    # user doesn't own the item.
    #
    # <b>Parameters</b>
    #
    # [item_Id] : the id of the item
    #
    ##
    def get_item(item_Id)
      fail "#{self.name} doesn't own object: \'#{item_Id}\'" unless (self.has_item?(item_Id.to_i))

      DAOItem.instance.fetch_item(item_Id)
    end
  end
end
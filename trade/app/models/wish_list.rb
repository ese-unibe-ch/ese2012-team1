#TODO all tests! (incl. doc)
module Models
  ##
  #
  # A WishList consists of an array of active items. A
  # account can add items to this whishlist to rememeber
  # that he is interrested in this item and to find
  # it faster.
  #
  # items : array of active items
  #
  ##
  class WishList
    attr_accessor :items

    ##
    #
    # initializes the item array
    #
    ##
    def initialize
      self.items = []
    end

    ##
    #
    # Deletes all inactive items from the wish list.
    #
    ##
    def update(item)
      self.items.delete(item) unless item.is_active?
      item.remove_observer(self)
      #puts "item #{item.name} has been deleted from your wish list, because it's inactive."
    end

    ##
    #
    #  Adds an item to this wishlist if the item is active
    #  Also tells the item to send a message to this wishlist
    #  if it becomes inactive
    #
    ##
    def add(item)
      fail "item is not active, it cannot be put in your wish list" unless item.is_active?
      self.items << item
      item.add_observer(self)
    end

    ##
    #
    #  Removes an item from this wishlist.
    #  Removes this wishlist from the observers of item
    #
    ##
    def remove(item)
      fail "item is not in your wish list" unless items.include?(item)
      item.remove_observer(self)
      self.items.delete(item)
    end
  end
end
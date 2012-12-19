module Models
  ##
  #
  # A WishList consists of an array of active items. An
  # account can add items to this whishlist to rememeber
  # that he is interested in this item and to find
  # it faster.
  #
  ##
  class WishList
    # array of active items
    attr_accessor :items

    ##
    #
    # Initializes the item array
    #
    ##
    def initialize
      self.items = []
    end

    ##
    #
    # Deletes all inactive items from the wish list.
    #
    # This method is called by Item.
    #
    # +item+:: Item to be deleted
    #
    ##
    def update(item)
      fail "missing item" if item.nil?

      self.items.delete(item) unless item.is_active?
      item.remove_observer(self)
    end

    ##
    #
    #  Adds an item to this wishlist if the item is active
    #  Also tells the item to send a message to this wishlist
    #  if it becomes inactive
    #
    #  +item+:: Item to be added (can't be nil, must be active)
    ##
    def add(item)
      fail "missing item" if item.nil?
      fail "item is not active, it cannot be put in your wish list" unless item.is_active?

      self.items << item
      item.add_observer(self)
    end

    ##
    #
    #  Removes an item from this wishlist.
    #  Removes this wishlist from the observers of item
    #
    #  +item+:: Item to be removed (can't be nil, must be already in wish list)
    #
    ##
    def remove(item)
      fail "missing item" if item.nil?
      fail "item is not in your wish list" unless items.include?(item)

      item.remove_observer(self)
      self.items.delete(item)
    end
  end
end
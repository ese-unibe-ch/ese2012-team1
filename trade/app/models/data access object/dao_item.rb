require 'singleton'

module Models
  class DAOItem
    include Singleton

    @items
    @item_id_count

    def initialize
      @items = Hash.new
      @item_id_count = 0
    end

    # --------item-------------------------------------------------------------

    ##
    #
    # Adds an item to the system and increments the id counter for items.
    #
    ##
    def add_item(item)
      fail "An items id should initially be nil, but was #{item.id}" unless (item.id == nil)
      fail "An item must have an owner when added to the system." if (item.owner == nil)
      item.id = @item_id_count
      @items.store(@item_id_count, item)
      @item_id_count += 1
    end

    ##
    #
    # Returns true if item exists in system. False in all other cases.
    #
    ##
    def item_exists?(item_id)
      @items.member?(item_id.to_i)
    end

    ##
    #
    # Returns the item with associated id.
    #
    ##
    def fetch_item(item_id)
      fail "No such item id: #{item_id}" unless @items.member?(item_id.to_i)
      @items.fetch(item_id.to_i)
    end

    ##
    #
    # Returns a hash with all items of this user.
    #
    ##
    def fetch_items_of(account_id)
      fail "No account with id #{account_id}" unless System.instance.accounts.member?(account_id)
      @items.values.select {|item| item.owner.id == account_id}
    end

    ##
    #
    # Returns a hash with all active items of this user.
    #
    ##
    def fetch_active_items_of(user_email)
      fail "No such user email" unless System.instance.fetch_user(user_email)
      user = System.instance.fetch_user(user_email)
      @items.values.select {| item| item.owner == user}.select {|i| i.active}
    end

    ##
    #
    # Returns all items but the ones of the specified user.
    #
    ##
    def fetch_all_items_but_of(account_id)
      fail "No account with id #{account_id}" unless System.instance.accounts.member?(account_id)
      @items.values.delete_if {|item| item.owner.id == account_id}
    end

    ##
    #
    # Returns all active items but the ones of the specified user.
    #
    ##
    def fetch_all_active_items_but_of(account_id)
      fail "No account with id #{account_id}" unless System.instance.accounts.member?(account_id)
      @items.values.select{|item| item.owner.id != account_id && item.active}
    end

    ##
    #
    # Returns all active items.
    #
    ##
    def fetch_all_active_items
      @items.values.select{|item| item.active}
    end

    ##
    #
    # Removes an item from the system
    # @see fetch_item
    #
    ##
    def remove_item(item_id)
      fail "There are no items" if @items.size == 0
      fail "No such item with id #{item_id}" unless @items.member?(item_id)
      @items.delete_if { |id, item| item.id == item_id }
    end
  end
end
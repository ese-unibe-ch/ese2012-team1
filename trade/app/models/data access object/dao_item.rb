require 'singleton'

module Models
  ##
  #
  # This class serves as data access object. It holds all items (identified by id).
  # It is implemented as a Singleton.
  #
  ##
  class DAOItem
    include Singleton

    @items # a hash that contains all item ids and associated item
    @item_id_count # counts how many items there are in the system

    def initialize
      @items = Hash.new
      @item_id_count = 0
    end

    # --------item-------------------------------------------------------------

    ##
    #
    # Adds an item to the system and sets the id of the item
    #
    # +item+:: item to be added
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
    # Returns true if item exists in system, false otherwise.
    #
    # +item_id+ id of the item to be checked (can't be nil)
    #
    ##
    def item_exists?(item_id)
      fail "Missing id" if item_id.nil?

      @items.member?(item_id.to_i)
    end

    ##
    #
    # Returns the item with associated id.
    #
    # +item_id+:: id of the item to be fetched (can't be nil and must exist in database)
    #
    ##
    def fetch_item(item_id)
      fail "Missing id" if item_id.nil?
      fail "No such item id: #{item_id}" unless @items.member?(item_id.to_i)
      @items.fetch(item_id.to_i)
    end

    ##
    #
    # Returns an array with all items of this user.
    #
    # +account_id+:: id of the Account whichs item are to be fetched (must exist in database)
    ##
    def fetch_items_of(account_id)
      fail "No account with id #{account_id}" unless DAOAccount.instance.account_exists?(account_id)
      @items.values.select {|item| item.owner.id == account_id}
    end

    ##
    #
    # Returns a hash with all active items of this account.
    #
    # +account_id+:: id of the Account whose item are to be fetched (must exist in database)
    ##
    def fetch_active_items_of(account_id)
      fetch_items_of(account_id.to_i).select {|s| s.is_active? }
    end

    ##
    #
    # Returns a hash with all inactive items of this account.
    #
    # +account_id+:: id of the Account whose item are to be fetched (must exist in database)
    ##
    def fetch_inactive_items_of(account_id)
      fetch_items_of(account_id.to_i).select {|s| !s.is_active? }
    end


    ##
    #
    # Returns all items but the ones of the specified user.
    #
    # +account_id+:: id of the Account whose item are to be fetched (must exist in database)
    ##
    def fetch_all_items_but_of(account_id)
      fail "No account with id #{account_id}" unless DAOAccount.instance.account_exists?(account_id)
      @items.values.delete_if {|item| item.owner.id == account_id}
    end

    ##
    #
    # Returns all active items but the ones of the specified user.
    #
    # +account_id+:: id of the Account whose item are to be fetched (must exist in database)
    ##
    def fetch_all_active_items_but_of(account_id)
      fail "No account with id #{account_id}" unless DAOAccount.instance.account_exists?(account_id)
      @items.values.select{|item| item.owner.id != account_id && item.active}
    end

    ##
    #
    # Returns all active items in the database.
    #
    ##
    def fetch_all_active_items
      @items.values.select{|item| item.active}
    end

    ##
    #
    # Removes an item from the system
    # (see #fetch_item)
    #
    # +item_id+:: id of the item to be removed (can't be nil and must exist in database)
    ##
    def remove_item(item_id)
      fail "There are no items" if @items.size == 0
      fail "No such item with id #{item_id}" unless @items.member?(item_id)
      @items.delete_if { |id, item| item.id == item_id }
    end

    ##
    #
    # Counts all items
    #
    # Returns count as Integer
    #
    ##
    def count_items
      @items.size
    end

    ##
    #
    # Resets item counter and removes all items
    #
    ##
    def reset
      @items = Hash.new
      @item_id_count = 0
    end
  end
end
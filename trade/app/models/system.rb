require 'singleton'
require 'rubygems'
require 'require_relative'

module Models
  # This class serves as some kind of database. It holds all organisations (identified by name),
  # all users (identified by email) and all items (identified by id).
  # It is implemented as a Singleton.
  class System
    include Singleton

    attr_accessor :accounts, :items, :item_id_count, :account_id_count

    def initialize
      self.accounts = Hash.new
      self.items = Hash.new
      self.item_id_count = 0
      self.account_id_count = 0
    end

    # ---------user------------------------------------------------------------

    # Adds an user to the system.
    def add_account(account)
      fail "No account" if (account == nil)
      fail "Account \'#{account}\' already exists" if (accounts.one? {|id, acc| acc == account })
      fail "Account should be set by this method" unless account.id == nil

      account.id = self.account_id_count
      self.accounts.store(account.id, account)
      self.account_id_count += 1

      fail "User should have correct id" unless (account.id == account_id_count-1)
      fail "User should be stored in users-hash" unless (self.accounts.member?(account_id_count-1))
    end

    # Returns the user with associated email.
    def fetch_account(account_id)
      fail "No account with id #{account_id}" unless self.accounts.member?(account_id)
      self.accounts.fetch(account_id)
    end

    # Returns all users but the one specified in an array
    def fetch_all_accounts_but(account_id)
      fail "No account with id #{account_id}" unless self.accounts.member?(account_id)
      self.accounts.values - [self.fetch_account(account_id)]  # Array difference
    end

    # Removes an user from the system.
    def remove_account(account_id)
      fail "No account with id #{account_id}" unless self.accounts.member?(account_id)
      self.accounts.delete(account_id)
    end

    # --------item-------------------------------------------------------------

    # Adds an item to the system and increments the id counter for items.
    def add_item(item)
      #preconditions
      fail "An items id should initially be nil, but was #{item.id}" unless (item.id == nil)
      fail "An item must have an owner when added to the system." if (item.owner == nil)
      item.id = item_id_count
      items.store(self.item_id_count, item)
      self.item_id_count += 1
    end

    # Returns the item with associated id.
    def fetch_item(item_id)
      fail "No such item id: #{item_id}" unless self.items.member?(item_id.to_i)
      self.items.fetch(item_id.to_i)
    end

    # Returns a hash with all items of this user.
    def fetch_items_of(account_id)
      fail "No account with id #{account_id}" unless self.accounts.member?(account_id)
      self.items.values.select {|item| item.owner.id == account_id}
    end

    # Returns all items but the ones of the specified user.
    def fetch_all_items_but_of(account_id)
      fail "No account with id #{account_id}" unless self.accounts.member?(account_id)
      self.items.values.delete_if {|item| item.owner.id == account_id}
    end

    # Returns all items but the ones of the specified user.
    def fetch_all_active_items_but_of(account_id)
      fail "No account with id #{account_id}" unless self.accounts.member?(account_id)
      self.items.values.select{|item| item.owner.id == account_id && item.active}
    end

    # Removes an item from the system
    # @see fetch_item
    def remove_item(item)
      fail "There are no items" if self.items.size == 0
      fail "No such item" unless self.items.member?(item.id)
      self.items.delete(item.id)
    end

    def fetch_organisations_of(account_nr)
      account = fetch_account(account_nr)
      accounts.values.select {|acc| acc.is_member?(account)}
    end

    #Removes all users, all items and resets the counter
    def reset
      self.accounts = Hash.new
      self.items = Hash.new
      self.item_id_count = 0
      self.account_id_count = 0
    end
  end
end
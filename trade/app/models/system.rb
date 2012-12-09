require 'singleton'

module Models
  ##
  #
  # This class serves as some kind of database. It holds all organisations (identified by name),
  # all users (identified by email) and all items (identified by id).
  # It is implemented as a Singleton.
  #
  # accounts : a hash that contains all account ids and associated accounts
  # items : a hash that contains all item ids and associated item
  # item_id_count : counts how many items there are in the system
  # account_id_count : counts how many accounts there are in the system
  # search : a search.rb object, that contains all registed accounts and items
  #
  ##
  class System
    include Singleton

    attr_accessor :accounts, :items, :item_id_count, :account_id_count, :search

    def initialize
      self.accounts = Hash.new
      self.items = Hash.new
      self.item_id_count = 0
      self.account_id_count = 0
      self.search = Search.new
    end

    # ---------accounts------------------------------------------------------------

    ##
    #
    # Adds an account to the system.
    #
    ##
    def add_account(account)
      fail "No account" if (account == nil)
      fail "Account \'#{account}\' already exists" if (accounts.one? {|id, acc| acc == account })
      fail "Account should be set by this method" unless account.id == nil

      account.id = self.account_id_count
      self.accounts.store(account.id, account)
      self.account_id_count += 1

      Messenger.instance.register(account.id)

      fail "User should have correct id" unless (account.id == account_id_count-1)
      fail "User should be stored in users-hash" unless (self.accounts.member?(account_id_count-1))
    end

    ##
    #
    # Returns the account with associated account id.
    #
    ##
    def fetch_account(account_id)
      fail "No account with id #{account_id}" unless account_exists?(account_id)
      self.accounts.fetch(account_id)
    end

    ##
    #
    # Checks if an account id exists
    #
    ##
    def account_exists?(account_id)
      self.accounts.member?(account_id)
    end

    ##
    #
    # Returns all accounts (users and organisations) but the one specified in an array
    #
    ##
    def fetch_all_accounts_but(account_id)
      fail "No account with id #{account_id}" unless self.accounts.member?(account_id)
      self.accounts.values - [self.fetch_account(account_id)]  # Array difference
    end

    ##
    #
    # Removes an account from the system.
    #
    ##
    def remove_account(account_id)
      fail "No account with id #{account_id}" unless self.accounts.member?(account_id)

      account = self.fetch_account(account_id)
      unless (account.avatar == "/images/users/default_avatar.png" || account.avatar == "/images/organisations/default_avatar.png")
        File.delete("#{account.avatar.sub("/images", "./public/images")}")
      end

      Messenger.instance.unregister(account_id)

      self.accounts.delete(account_id)
    end

    # ---------users ------------------------------------------------------------

    ##
    #
    # returns the user with the specified email
    #
    ##
    def fetch_user_by_email(email)
      self.accounts.values.detect{|account| account.respond_to?(:email) && account.email == email}
    end

    ##
    #
    # returns the user with the specified registration hash
    #
    ##
    def fetch_user_by_reg_hash(hash)
      self.accounts.values.detect{|account| !account.organisation && account.reg_hash == hash}
    end


    ##
    #
    # Checks if a user email exists
    #
    ##
    def user_exists?(email)
      self.accounts.values.one?{|account| account.respond_to?(:email) && account.email == email}
    end

    ##
    #
    # Returns true if there is a user with this reg_hash in the system
    #
    ##
    def reg_hash_exists?(hash)
      self.accounts.values.one?{|account| !account.organisation && account.reg_hash == hash}
    end

    ##
    #
    # Returns all users but the one specified in an array
    #
    ##
    def fetch_all_users_but(account_id)
      fail "No account with id #{account_id}" unless self.accounts.member?(account_id)
      tmp = accounts.values.select{|acc| acc.organisation == false}
      tmp.select{|acc| acc.id != account_id}
    end


    # --------item-------------------------------------------------------------

    ##
    #
    # Adds an item to the system and increments the id counter for items.
    #
    ##
    def add_item(item)
      #preconditions
      fail "An items id should initially be nil, but was #{item.id}" unless (item.id == nil)
      fail "An item must have an owner when added to the system." if (item.owner == nil)
      item.id = item_id_count
      items.store(self.item_id_count, item)
      self.item_id_count += 1
    end

    ##
    #
    # Returns true if item exists in system. False in all other cases.
    #
    ##
    def item_exists?(item_id)
      self.items.member?(item_id.to_i)
    end

    ##
    #
    # Returns the item with associated id.
    #
    ##
    def fetch_item(item_id)
      fail "No such item id: #{item_id}" unless self.items.member?(item_id.to_i)
      self.items.fetch(item_id.to_i)
    end

    ##
    #
    # Returns a hash with all items of this user.
    #
    ##
    def fetch_items_of(account_id)
      fail "No account with id #{account_id}" unless self.accounts.member?(account_id)
      self.items.values.select {|item| item.owner.id == account_id}
    end

    ##
    #
    # Returns a hash with all active items of this user.
    #
    ##
    def fetch_active_items_of(user_email)
      fail "No such user email" unless self.fetch_user(user_email)
      user = self.fetch_user(user_email)
      self.items.values.select {| item| item.owner == user}.select {|i| i.active}
    end

    ##
    #
    # Returns all items but the ones of the specified user.
    #
    ##
    def fetch_all_items_but_of(account_id)
      fail "No account with id #{account_id}" unless self.accounts.member?(account_id)
      self.items.values.delete_if {|item| item.owner.id == account_id}
    end

    ##
    #
    # Returns all active items but the ones of the specified user.
    #
    ##
    def fetch_all_active_items_but_of(account_id)
      fail "No account with id #{account_id}" unless self.accounts.member?(account_id)
      self.items.values.select{|item| item.owner.id != account_id && item.active}
    end

    ##
    #
    # Returns all active items.
    #
    ##
    def fetch_all_active_items
      self.items.values.select{|item| item.active}
    end

    ##
    #
    # Removes an item from the system
    # @see fetch_item
    #
    ##
    def remove_item(item_id)
      fail "There are no items" if self.items.size == 0
      fail "No such item with id #{item_id}" unless self.items.member?(item_id)
      self.items.delete_if { |id, item| item.id == item_id }
    end
   # ------------------------- organisation --------------------------------------------

    ##
    #
    # Returns all organisations in which a user is a member
    #
    ##
    def fetch_organisations_of(account_nr)
      account = fetch_account(account_nr)
      accounts.values.select {|acc| acc.is_member?(account)}
    end

    ##
    #
    # Returns the organisation with the specified name
    #
    ##
    def fetch_organisation_by_name(organisation_name)
      accounts.values.detect{|acc| !acc.respond_to?(:email) && acc.name == organisation_name}
    end

    ##
    #
    # Returns all organisations but the specified
    #
    ##
    def fetch_organisations_but(organisation_id)
      tmp = accounts.values.select{|acc| acc.organisation == true}
      tmp.select{|acc| acc.id != organisation_id}
    end

    ##
    #
    # Checks if an organisation with the specified name exists
    #
    ##
    def organisation_exists?(organisation_name)
      self.accounts.values.one?{|acc| !acc.respond_to?(:email) && acc.name == organisation_name}
    end

    #TODO test
    ##
    #
    # Checks if a user is admin of any organisation
    #
    ##
    def admin_of_an_organisation?(user)
      org = self.fetch_organisations_of(user.id)
      org.one? { |organisation| organisation.is_admin?(user) }
    end

    ##
    #
    # Resets all limits for all organisations members
    #
    ##
    def reset_all_member_limits
      orgs = accounts.values.select{|acc| acc.organisation == true}
      for org in orgs
        org.reset_member_limits
      end
    end

    ##
    #
    # Removes all users, all items and resets the counters
    #
    ##
    def reset
      self.accounts = Hash.new
      self.items = Hash.new
      self.item_id_count = 0
      self.account_id_count = 0
    end
  end
end
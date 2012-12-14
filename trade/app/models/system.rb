require 'singleton'

module Models
  ##
  #
  # This class serves as data access object. It holds all organisations (identified by name),
  # all users (identified by email) and all items (identified by id).
  # It is implemented as a Singleton.
  #
  # accounts : a hash that contains all account ids and associated accounts
  # items : a hash that contains all item ids and associated item
  # item_id_count : counts how many items there are in the system
  # account_id_count : counts how many accounts there are in the system
  # search : a search.rb object, that contains all registered accounts and items
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
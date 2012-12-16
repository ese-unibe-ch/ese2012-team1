require 'singleton'

module Models
  ##
  #
  # This class serves as data access object. It holds all organisations (identified by name),
  # and all users (identified by email)-
  # It is implemented as a Singleton.
  #
  ##

  class DAOAccount
    include Singleton

    @accounts
    @account_id_count

    def initialize
      @accounts = Hash.new
      @account_id_count = 0
    end

    # ---------accounts------------------------------------------------------------

    ##
    #
    # Adds an account to the system.
    #
    ##
    def add_account(account)
      fail "No account" if (account == nil)
      fail "Account \'#{account}\' already exists" if (@accounts.one? {|id, acc| acc == account })
      fail "Account id should be set by this method" unless account.id == nil

      account.id = @account_id_count
      @accounts.store(account.id, account)
      @account_id_count += 1

      Messenger.instance.register(account.id)

      fail "User should have correct id" unless (account.id == @account_id_count-1)
      fail "User should be stored in users-hash" unless (@accounts.member?(@account_id_count-1))
    end

    ##
    #
    # Returns the account with associated account id.
    #
    ##
    def fetch_account(account_id)
      fail "No account with id #{account_id}" unless account_exists?(account_id)
      @accounts.fetch(account_id)
    end

    ##
    #
    # Checks if an account id exists
    #
    ##
    def account_exists?(account_id)
      @accounts.member?(account_id)
    end

    ##
    #
    # Returns all accounts (users and organisations) but the one specified in an array
    #
    ##
    def fetch_all_accounts_but(account_id)
      fail "No account with id #{account_id}" unless @accounts.member?(account_id)
      @accounts.values - [self.fetch_account(account_id)]  # Array difference
    end

    ##
    #
    # Removes an account from the system.
    #
    ##
    def remove_account(account_id)
      fail "No account with id #{account_id}" unless @accounts.member?(account_id)

      account = self.fetch_account(account_id)
      unless (account.avatar == "/images/users/default_avatar.png" || account.avatar == "/images/organisations/default_avatar.png")
        File.delete("#{account.avatar.sub("/images", "./public/images")}")
      end

      Messenger.instance.unregister(account_id)

      @accounts.delete(account_id)
    end

    # ---------users ------------------------------------------------------------

    ##
    #
    # returns the user with the specified email
    #
    ##
    def fetch_user_by_email(email)
      @accounts.values.detect{|account| account.respond_to?(:email) && account.email == email}
    end

    ##
    #
    # returns the user with the specified registration hash
    #
    ##
    def fetch_user_by_reg_hash(hash)
      @accounts.values.detect{|account| !account.organisation && account.reg_hash == hash}
    end


    ##
    #
    # Checks if a user email exists
    #
    ##
    def email_exists?(email)
      @accounts.values.one?{|account| account.respond_to?(:email) && account.email == email}
    end

    ##
    #
    # Checks if a user with a specific id exists
    #
    ##
    def user_exists?(user_id)
      @accounts.member?(user_id)
    end

    ##
    #
    # Returns true if there is a user with this reg_hash in the system
    #
    ##
    def reg_hash_exists?(hash)
      @accounts.values.one?{|account| !account.organisation && account.reg_hash == hash}
    end

    ##
    #
    # Returns all users but the one specified in an array
    #
    ##
    def fetch_all_users_but(account_id)
      fail "No account with id #{account_id}" unless @accounts.member?(account_id)
      tmp = @accounts.values.select{|acc| acc.organisation == false}
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
      @accounts.values.select {|acc| acc.is_member?(account)}
    end

    ##
    #
    # Returns the organisation with the specified name
    #
    ##
    def fetch_organisation_by_name(organisation_name)
      @accounts.values.detect{|acc| !acc.respond_to?(:email) && acc.name == organisation_name}
    end

    ##
    #
    # Returns all organisations but the specified
    #
    ##
    def fetch_organisations_but(organisation_id)
      tmp = @accounts.values.select{|acc| acc.organisation == true}
      tmp.select{|acc| acc.id != organisation_id}
    end

    ##
    #
    # Checks if an organisation with the specified name exists
    #
    ##
    def organisation_exists?(organisation_name)
      @accounts.values.one?{|acc| !acc.respond_to?(:email) && acc.name == organisation_name}
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
    # Checks if this user is the last admin of any organisation
    #
    ##
    def is_last_admin?(user)
      organisations = fetch_organisations_of(user.id)
      organisations.one? { |organisation| organisation.is_last_admin?(user)}
    end

    ##
    #
    # Resets all limits for all organisations members
    #
    ##
    def reset_all_member_limits
      orgs = @accounts.values.select{|acc| acc.organisation == true}
      for org in orgs
        org.reset_member_limits
      end
    end

    ##
    #
    # Counts all accounts
    #
    ##

    def count_accounts
      @accounts.size
    end

    ##
    #
    # Resets counter and removes all accounts
    #
    ##

    def reset
      @accounts = Hash.new
      @account_id_count = 0
    end
  end
end
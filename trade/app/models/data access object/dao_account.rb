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
    # Adds an Account to the system and sets a specifique id
    # for it. Registers the account to the Messenger.
    #
    # +account+:: account to be added (can't be nil, ,mustn't exist in database already, can't have an id already)
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
    # Returns the Account with associated account id.
    #
    # +account_id+:: id of the account to be fetched (must exist in database)
    #
    ##
    def fetch_account(account_id)
      fail "No account with id #{account_id}" unless account_exists?(account_id)
      @accounts.fetch(account_id)
    end

    ##
    #
    # Checks if an Account exists
    #
    # Returns true if the Account with the
    # associated account id is saved in the
    # database
    #
    # +account_id+:: id of the account to be checked
    ##
    def account_exists?(account_id)
      @accounts.member?(account_id)
    end

    ##
    #
    # Returns an array of all Accounts (users and organisations)
    # saved in the database but the one specified
    #
    # +account_id+:: id of the account not to be returned (must exist in database)
    ##
    def fetch_all_accounts_but(account_id)
      fail "No account with id #{account_id}" unless @accounts.member?(account_id)
      @accounts.values - [self.fetch_account(account_id)]  # Array difference
    end

    ##
    #
    # Removes an account from the database.
    #
    ##
    def remove_account(account_id)
      fail "No account with id #{account_id}" unless @accounts.member?(account_id)

      Messenger.instance.unregister(account_id)

      @accounts.delete(account_id)
    end

    # ---------users ------------------------------------------------------------

    ##
    #
    # Returns the user with the specified email.
    # Returns nil if no user was found.
    #
    # This method is used in the login process
    # because the id of the user is not known then.
    #
    # +email+:: E-mail of the user to be fetched
    ##
    def fetch_user_by_email(email)
      @accounts.values.detect{|account| account.respond_to?(:email) && account.email == email}
    end


    ##
    #
    # Checks if a user e-mail exists.
    #
    # Returns true if the given +email+
    # exists in database, false otherwise.
    #
    # This method is used in the login process
    # because the id of the user is not known then.
    #
    # +email+:: E-mail of the user to be checked
    ##
    def email_exists?(email)
      @accounts.values.one?{|account| account.respond_to?(:email) && account.email == email}
    end


    ##
    #
    # Returns the user with the specified registration hash.
    # Returns nil if no user was found.
    #
    # This method is used in the registration process
    # to securely identify the user.
    #
    # +hash+:: Registration hash of the user to be fetched
    #
    ##
    def fetch_user_by_reg_hash(hash)
      @accounts.values.detect{|account| !account.organisation && account.reg_hash == hash}
    end

    ##
    #
    # Returns true if there is a user with the given
    # registration hash in the database, false
    # otherwise.
    #
    # +hash+:: Registration hash of the user to be checked
    #
    ##
    def reg_hash_exists?(hash)
      @accounts.values.one?{|account| !account.organisation && account.reg_hash == hash}
    end

    ##
    #
    # Returns all users (meaning where user#organisation returns false) but
    # the one specified in an array
    #
    # +user_id+:: user not to be fetched (must exist in database)
    ##
    def fetch_all_users_but(user_id)
      fail "No account with id #{user_id}" unless @accounts.member?(user_id)
      tmp = @accounts.values.select{|acc| acc.organisation == false && acc.id != user_id}
    end

    # ------------------------- organisation --------------------------------------------

    ##
    #
    # Returns all organisations in which a user is a member
    #
    # +account_id+ id of user
    #
    ##
    def fetch_organisations_of(account_id)
      account = fetch_account(account_id)
      @accounts.values.select {|acc| acc.is_member?(account)}
    end

    ##
    #
    # Returns the organisation with the specified name
    #
    # +organisation_name+:: name of the organisation to be fetched
    #
    ##
    def fetch_organisation_by_name(organisation_name)
      @accounts.values.detect{|acc| !acc.respond_to?(:email) && acc.name == organisation_name}
    end

    ##
    #
    # Returns all organisations but the specified
    #
    # +organisation_id+:: id of the organisation not to be fetched
    #
    ##
    def fetch_organisations_but(organisation_id)
      tmp = @accounts.values.select{|acc| acc.organisation == true}
      tmp.select{|acc| acc.id != organisation_id}
    end

    ##
    #
    # Checks if an organisation with the specified
    # name exists
    #
    # Returns true if organisation exists, false
    # otherwise.
    #
    # +organisation_name+:: Name of the organisation.
    #
    ##
    def organisation_exists?(organisation_name)
      @accounts.values.one?{|acc| !acc.respond_to?(:email) && acc.name == organisation_name}
    end

    ##
    #
    # Checks if a user is admin of any organisation
    #
    # Returns true if the user is admin of any
    # organisation.
    #
    # +user+ User to be checked (an Account)
    #
    ##
    def admin_of_an_organisation?(user)
      org = self.fetch_organisations_of(user.id)
      org.one? { |organisation| organisation.is_admin?(user) }
    end


    ##
    #
    # Checks if this user is the last admin of any organisation.
    #
    # Returns true if the given +user+ is the last admin
    # of any organisation, false otherwise.
    #
    # +user+ User to be checked (an Account)
    ##
    def is_last_admin?(user)
      organisations = fetch_organisations_of(user.id)
      organisations.one? { |organisation| organisation.is_last_admin?(user)}
    end

    ##
    #
    # Resets all member limits in all
    # organisations (see Organisation)
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
    # Returns the count of all accounts as
    # Integer.
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
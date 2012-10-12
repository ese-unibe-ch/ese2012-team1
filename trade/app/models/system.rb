
module Models

  class System

    attr_accessor :users, :items, :item_id_count
    @@instance  = self.new
    @@instantiated =false



    def initialize
      self.organisation = {}
      self.users = {}
      self.items = {}
      self.item_id_count = 0
      self
    end


    def self.instance
      if (@instantiated == nil)
        @instance=Models::System.new
        @instantiated = true
      else
        @instance
      end
    end

    def add_user(user)
      self.users.store(user.email, user)
    end

    # Returns the user with associated email.
    def self.fetch_user(user_email)
      fail "No user with email #{user_email}" unless self.users.member?(user_email)
      self.users.fetch(user_email)
    end

    # Returns all users but the one specified in a array
    def self.fetch_all_users_but(user_email)
      fail "No user with email #{user_email}" unless self.users.member?(user_email)
      self.users.values - [user_email] # Array difference
    end

    # Removes an user from the system.
    def self.remove_user(user_email)
      fail "No user with email #{user_email}" unless self.users.member?(user_email)
      self.users.delete(user_email)
    end

    # Checks if mail if an user exists with this mail.
    # @param [mail] user_email
    def self.mail_unique?(user_email)
      list = self.users.collect { |user| user.email == user_email }
      if   (list.length > 0)
        false
      else
        true
      end
    end

    def get_users
      @us
    end

    # --------item-------------------------------------------------------------

    # Adds an item to the system and increments the id counter for items.
    def add_item(item)
      fail "An item must have an owner when added to the system." if (item.owner == nil)
      items.stores(:item_id_count, item)
      item.id = item_id_count + 1
    end

    # Returns the item with associated id.
    def fetch_item(item_id)
      fail "No such item id" if self.items.contains(item_id)
      self.items.fetch(item_id)
    end

    # Returns a hash with all items of this user.
    def fetch_items_of(user_email)
      fail "No such user email" if self.users.contains(user_email)
      user = self.fetch_user(user_email)
      self.items.each { |id, item| item.get_owner == user }
    end

    # Returns all items but the ones of the specified user.
    def fetch_all_items_but_of(user_email)
      fail "No such user email" if self.users.contains(user_email)
      user = self.fetch_user(user_email)
      self.items.each { |id, item| item.get_owner != user }
    end

    # Removes an item from the system
    # @see fetch_item
    def remove_item(item)
      fail "There are no items" if self.items.size == 0
      fail "No such item id" if self.items.contains(item_id)
      items.delete(item)
    end

    # ---- organisation ---------------------

    # Adds an item to the system and increments the id counter for items.
    def add_organisation(org)
      fail "No organisation" if (user == nil)
      organisation.store(org.get_name, org)
    end

    # Returns the organisation with associated name.
    def fetch_organisation(org_name)
      fail "No such organisation name" if self.organisation.contains(org_name)
      self.organisation.fetch(org_name)
    end

    # Returns a list of all the users organisations
    def fetch_organisations_of(user_email)
      fail "No such user email" if self.users.contains(user_email)
      user = self.fetch_user(user_email)
      self.organisation.each { |org_name, org| org.is_member?(user) }
    end

    # Removes an organisation from the system.
    def remove_organisation(org_name)
      fail "No such organisation name found" if self.organisation.contains(org_name)
      organisations.delete(org_name)
    end

  end
end

require 'singleton'
require 'rubygems'
require 'require_relative'
require_relative('organisation')

module Models
  # This class serves as some kind of database. It holds all organisations (identified by name),
  # all users (identified by email) and all items (identified by id).
  # It is implemented as a Singleton.
  class System
    include Singleton

    attr_accessor :organisation, :users, :items, :item_id_count

    def initialize
      self.organisation = Hash.new
      self.users = Hash.new
      self.items = Hash.new
      self.item_id_count = 0
    end

    # ---------user------------------------------------------------------------

    # Adds an user to the system.
    def add_user(user)
      fail "No user" if (user == nil)
      fail "User already exists" if (users.member?(user.email))
      self.users.store(user.email, user)
    end

    # Returns the user with associated email.
    def fetch_user(user_email)
      fail "No user with email #{user_email}" unless self.users.member?(user_email)
      self.users.fetch(user_email)
    end

    # Returns all users but the one specified in an array
    def fetch_all_users_but(user_email)
      fail "No user with email #{user_email}" unless self.users.member?(user_email)
      self.users.values - [fetch_user(user_email)]  # Array difference
    end

    # Removes an user from the system.
    def remove_user(user_email)
      fail "No user with email #{user_email}" unless self.users.member?(user_email)
      self.users.delete(user_email)
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
    def fetch_items_of(user_email)
      fail "No such user email" unless self.fetch_user(user_email)
      user = self.fetch_user(user_email)
      self.items.values.select {| item| item.owner == user}
    end

    # Returns all items but the ones of the specified user.
    def fetch_all_items_but_of(user_email)
      fail "No such user email" unless self.users.member?(user_email)
      user = self.fetch_user(user_email)
      self.items.delete_if {|name, item| item.owner == user}
    end

    # Removes an item from the system
    # @see fetch_item
    def remove_item(item)
      fail "There are no items" if self.items.size == 0
      fail "No such item" unless self.items.member?(item.id)
      item = self.items.delete(item.id)
    end

    # ---- organisation ---------------------

    # Adds an organisation to the system.
    def add_organisation(org)
      fail "No organisation" if (org == nil)
      organisation.store(org.get_name, org)
    end

    # Returns the organisation with associated name.
    def fetch_organisation(org_name)
      fail "No such organisation name" unless self.organisation.member?(org_name)
      self.organisation.fetch(org_name)
    end

    # Returns a list of all the user's organisations
    def fetch_organisations_of(user_email)
      fail "No such user email #{user_email}" unless self.users.member?(user_email)
      user = self.fetch_user(user_email)
      self.organisation.each{|org_name, org| org.is_member?(user)}
    end

    # Removes an organisation from the system.
    def remove_organisation(org_name)
      fail "No such organisation name found" unless self.organisation.member?(org_name)
      organisation.delete(org_name)
    end

  end
end
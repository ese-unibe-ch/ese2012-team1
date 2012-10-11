require 'singleton'

module Models
  # This class serves as some kind of database. It holds all organisations (identified by name),
  # all users (identified by email) and all items (identified by id).
  # It is implemented as a Singleton.
  class System
    include Singleton

    attr_accessor :organisation, :users, :items, :item_id_count

    def initialize
      self.organisation = {}
      self.users = {}
      self.items = {}
      self.item_id_count = 0
    end


    # Adds an user to the system.
    def add_user(user)
      fail "No user" if (user == nil)
      self.users.store(user.email, user)
    end

    # Returns the user with associated email.
    def fetch_user(user_email)
      fail "No user with email #{user_email}" if self.users.member?(user_email)
      self.users.fetch(user_email)
    end

    # Removes an user from the system.
    def remove_user(user_email)
      fail "No user with email #{user_email}" if self.users.member?(user_email)
      self.users.delete(user_email)
    end

    def fetch_all_users_but(user_email)
      fail "No user with email #{user_email}" if self.users.member?(user_email)
      self.users.values - [user_email]  # Array difference
    end



    # Adds an item to the system and increments the id counter for items.
    def add_item(item)
      fail"An item must have an owner when added to the system." if (item.owner == nil)
      items = {:item_id_count => item}
      item.id = item_id_count + 1
    end


  end
end
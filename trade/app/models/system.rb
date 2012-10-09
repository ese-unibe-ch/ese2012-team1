require 'singleton'

module Models

  class System
    include Singleton

    attr_accessor :users, :items, :item_id_count

    def initialize
      self.users ={}
      self.items ={}
      self.item_id_count = 0
    end

    def add_user(user)
      self.users.store(user.email, user)
    end

    def add_item(item)
      items = {:item_id_count => item}
      item.id = item_id_count + 1
    end

    def remove_user_by_id(user_id)

    end

    def remove_user(user)

    end

  end
end
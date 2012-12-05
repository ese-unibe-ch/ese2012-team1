#TODO all tests! (incl. doc)
module Models
  class WishList
    attr_accessor :items

    def initialize
      self.items = []
    end

    def update(item)
      self.items.delete(item) unless item.is_active?
      item.remove_observer(self)
      puts "item #{item.name} has been deleted from your wish list, because it's inactive."
    end

    def add(item)
      fail "item is not active, it cannot be put in your wish list" unless item.is_active?
      self.items << item
      item.add_observer(self)
    end

    def remove(item)
      fail "item is not in your wish list" unless items.include?(item)
      self.items.delete(item)
    end
  end
end
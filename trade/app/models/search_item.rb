#Abstract Class

class SearchItem
  attr_accessor :item, :symbol_methods, :name, :method_priority, :user_priority

  def initialize
    self.method_priority = 1
  end

  def self.create(item, name, symbol_methods)
    search_item = self.new
    search_item.item = item
    search_item.name = name
    search_item.symbol_methods = symbol_methods

    search_item
  end

  def priority_of_user(user_id)
    self.part_of?(user_id) ? 1 : 2
  end

  ##
  #
  # Checks if the user with the given user_id is part
  # of the SearchItem
  #
  ##

  def part_of?(user_id)
    fail "To be implemented by child"
  end
end
#Abstract Class

module Models

  ##
  #
  #  Responsibility:
  #  Holding the methods to be called when performing
  #  a Search (see Search). Provides the priorities of
  #  of the user performing a search.
  #
  ##

  class SearchItem
    attr_accessor :item, :symbol_methods, :name, :user_priority

    ##
    #
    # Creates a SearchItem holding an item (normally User
    # Organisation or Item), a name and methods to be called.
    #
    # The given methods should be provided as symbols and
    # should return an Object that can respond to #include?
    # The order the methods are provided serve for the
    # priorities returned in #priority_of_method.
    #
    # When performing a search the items a group by the
    # given name (see Search and SearchResult).
    #
    # Params:
    # item: item to be called by symbol_methods
    # name: Name by which item should be grouped
    # symbol_methods: Array of methods (provided as symbols)
    #
    ##

    def self.create(item, name, symbol_methods)
      search_item = self.new
      search_item.item = item
      search_item.name = name
      search_item.symbol_methods = symbol_methods

      search_item
    end

    ##
    #
    # Returns 1 it the user with the given id is part
    # part of the item stored. Returns 2 if not.
    #
    ##

    def priority_of_user(user_id)
      fail "User does not exist" unless DAOAccount.instance.account_exists?(user_id)

      self.part_of?(user_id) ? 1 : 2
    end

    ##
    #
    # Returns the priority of the method. (see SearchResult#sort!)
    # The priority is determined through the order of
    # the Array given in create (see #create)
    #
    # This method is not yet used!
    ##

    def priority_of_method(symbol_method)
      priority = self.symbol_methods.index(symbol_method)

      fail "No such method in SearchItem" if (priority.nil?)

      return priority+1
    end

    ##
    #
    # Checks if the user with the given user_id is part
    # of the SearchItem. Return true if this is the
    # case.
    #
    ##

    def part_of?(user_id)
      fail "To be implemented by child"
    end
  end
end
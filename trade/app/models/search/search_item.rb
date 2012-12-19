module Models

  ##
  #  This is an abstract class (see SearchItemItem,
  #  SearchItemOrganisation and SearchItemUser for
  #  implementations)
  #
  #  === Responsibility
  #
  #  Holding the methods to be called when performing
  #  a Search (see Search). Provides the priority for
  #  user performing a search (see #priority_of_user).
  #
  ##

  class SearchItem
    #Item associated with this SearchItem
    attr_accessor :item
    #Methods to be checked by a search
    attr_accessor :methods
    #Name by which item can be grouped (see SearchResult)
    attr_accessor :name

    ##
    #
    # Creates a SearchItem holding an item (normally User
    # Organisation or Item), a name and methods to be called.
    #
    # The given methods should be provided as symbols and
    # should return an object that can respond to #include?
    # The order the methods are provided serve for the
    # priorities returned in #priority_of_method.
    #
    # When performing a search the items a group by the
    # given name (see Search and SearchResult).
    #
    # === Parameters
    #
    # +item+:: item to be called by the given +methods+
    # +name+:: Name by which item is grouped
    # +methods+:: Array of methods (provided as symbols)
    #
    ##

    def self.create(item, name, methods)
      search_item = self.new
      search_item.item = item
      search_item.name = name
      search_item.methods = methods

      search_item
    end

    ##
    #
    # Returns 1 if the user with the given id is
    # part of the item stored (see SearchResult#sort!). Returns 2 if not.
    # The method #part_of must be implemented by the
    # inheriting  class (see SearchItemItem for an
    # example)
    #
    # +user_id+:: id of the user performing this search (id must exist in database)
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
    # +method+:: method to get priority for (must exist in array methods (see #create))
    ##

    def priority_of_method(method)
      priority = self.methods.index(method)

      fail "No such method in SearchItem" if (priority.nil?)

      return priority+1
    end

    ##
    #
    # Checks if the user with the given user_id is part
    # of the SearchItem. Returns true if this is the
    # case. Has to be implemented by inheriting class
    # (see SearchItemOrganisation for an example).
    #
    # This method determines the priority for #priority_of_user
    # If user is part of the item hold in this SearchItem
    # then the priority is higher ergo it appears more at the
    # front of the SearchResult.
    #
    # === Parameters
    #
    # +user_id+:: id of the user to be checked
    #
    ##

    def part_of?(user_id)
      fail "To be implemented by child"
    end
  end
end
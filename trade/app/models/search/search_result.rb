module Models
  ##
  #
  # Stores results and the pattern that leaded to this result.
  # Used by Search to return results to a client.
  #
  ##


  class SearchResult
    attr_accessor :result, # all results saved as Hash (see #initialize)
                  :pattern # pattern used to get objects stored in result

    def initialize
      self.result = Hash.new
    end

    ##
    #
    # Adds a new result and its priority.
    # Priority is used by #sort! to sort all
    # results and detetermine they are returned in
    # #get
    #
    # Params:
    # item: a SearchItem Object
    # priority: Priority used by #sort!
    #
    ##

    def add(item, priority)
      unless result[item.name]
        self.result[item.name] = Array.new
      end

      self.result[item.name].push({ :item => item, :priority => priority })
    end

    ##
    #
    # Returns a list of items stored with the given name. Fails
    # if there are no results of this name.
    #
    # The name is determined by items given in #add.
    # At the moment we use the names "organisation", "user"
    # and "item". So this method returns either a list of
    # Organisations, Users or Items.
    #
    # Params:
    # name: Name to get the list of
    #
    ##

    def get(name)
      fail "There is no result for \'#{name}\'" unless self.found?(name)

      self.result[name].collect{ |item| item[:item].item }
    end

    ##
    #
    # Sorts the SearchResults by two priorities. The first
    # priority is if the result belongs to the user that sorts
    # and the second priority is the method where the result is
    # coming from. To learn more about how the second priority
    # is set see Search.
    #
    # A short example: If you have a list containing the
    # following items:
    # 1) Pattern found in Description of Item belonging to userA
    # 2) Pattern found in Item name belonging to userA
    # 3) Pattern found in Description of userB
    # 4) Pattern found in Name of Organisation where userB belongs to
    # 5) Pattern found in Description of Organisation where userB belongs to
    #
    # Then after #sort!(id_of_user_B) the list is sorted like this:
    # a) 4)
    # b) 3)
    # c) 5)
    # c) 2)
    # d) 1)
    #
    # 4), 3) and 5) are before 2) and 1) because the user that performs the search
    # is ranked before all other users. 4) is ranked before 3) and 5) because
    # names are ranked higher than descriptions. You can not make any assumption
    # about the ranking of 3) and 5) because they have the same priority. See
    # Search for more information.
    #
    # Params:
    # user_id: The id of the user that is doing this sort
    #
    ##

    def sort!(user_id)
      self.result.each do |name, items|
        items.sort! do |a, b|
          [a[:item].priority_of_user(user_id), a[:priority]] <=> [b[:item].priority_of_user(user_id), b[:priority]]
        end
      end

      self
    end

    ##
    #
    # Checks if there are results for the given name
    # Returns true if there are.
    #
    # Example: If you want to check if there are results
    # for an organisation then use:
    #
    # #found?("organisation")
    #
    ##

    def found?(name)
      result.member?(name)
    end

    ##
    #
    # Checks if there are any results at all
    # Returns true if there are.
    #
    ##

    def empty?
      self.result.empty?
    end

    def size
      self.result.size
    end
  end
end

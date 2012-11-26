module Models

  ##
  #
  # Responsibility:
  # Hold SearchItems and scan them for a specifique string.
  # Provide a SearchResult holding the results of the
  # search.
  #
  ##

  class Search
    attr_accessor :items

    def initialize
      self.items = Array.new
    end

    ##
    #
    # Search through all registered items (see #register) for a
    # given string and returns all items including that string
    # as a SearchResult (see SearchResult). The search is
    # case insensitive.
    #
    # Params:
    # search_string: String to be searched for
    #
    ##

    def find(search_string)
      result = SearchResult.new
      result.pattern = search_string

      items.each do |item|
        item.symbol_methods.each_with_index do |symbol_method, index|
          if item.item.send(symbol_method).downcase.include?(search_string.downcase)
            result.add(item, index+1)
            break
          end
        end
      end

      result
    end

    ##
    #
    # Registers a SearchItem (see SearchItem) to
    # the search in #find.
    #
    # Params:
    # search_item: a SearchItem
    #
    ##

    def register(search_item)
      items.push(search_item)
    end

    ##
    #
    # Removes an item from the search. This has
    # to be the original item that was added.
    # At the moment those are User, Organisation
    # or Item.
    #
    # Params:
    # original_item: Item to be unregistered
    #
    ##

    def unregister(original_item)
      self.items = self.items.delete_if { |item| item.item == original_item }
    end
  end
end
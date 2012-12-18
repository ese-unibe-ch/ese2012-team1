module Models

  ##
  #
  # This class performs a search over various registered
  # items. In our case these are items (see Item),
  # users (see User) and organisations (see Organisation).
  #
  # You can register and unregister SearchItem to this
  # search.
  #
  # === Responsibility
  #
  # Hold SearchItems and scan them for a specific string.
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
    # Searches through all registered items (see #register) for a
    # given string and returns all items including +search_string+
    # as a SearchResult (see SearchResult). The search is
    # case insensitive.
    #
    # === Parameters
    #
    # +search_string+:: String to be searched for
    #
    ##

    def find(search_string)
      result = SearchResult.new
      result.pattern = search_string

      items.each do |item|
        item.methods.each_with_index do |method, index|
          if item.item.send(method).downcase.include?(search_string.downcase)
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
    # === Parameters
    #
    # +search_item+:: A SearchItem
    #
    ##

    def register(search_item)
      items.push(search_item)
    end

    ##
    #
    # Removes an item from the search. This has
    # to be the original item that was added not the
    # SearchItem. So the user of this Search has
    # not to save all SearchItems he creates.
    #
    # At the moment those are User, Organisation
    # or Item.
    #
    # === Parameters
    #
    # original_item: item to be unregistered
    #
    ##

    def unregister(original_item)
      self.items = self.items.delete_if { |item| item.item == original_item }
    end
  end
end
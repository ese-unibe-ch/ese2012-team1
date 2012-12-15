require 'singleton'

module Models
  ##
  #
  # This class serves as data access object. It holds all organisations (identified by name),
  # all users (identified by email) and all items (identified by id).
  # It is implemented as a Singleton.
  #
  # accounts : a hash that contains all account ids and associated accounts
  # items : a hash that contains all item ids and associated item
  # item_id_count : counts how many items there are in the system
  # account_id_count : counts how many accounts there are in the system
  # search : a search.rb object, that contains all registered accounts and items
  #
  ##
  class System
    include Singleton
    attr_accessor :search

    def initialize
      @search = Search.new
    end

    ##
    #
    # Removes all users, all items and resets the counters
    #
    ##
    def reset
      self.accounts = Hash.new
      self.items = Hash.new
      self.item_id_count = 0
      self.account_id_count = 0
    end
  end
end
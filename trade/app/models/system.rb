require 'singleton'

module Models
  ##
  #
  # It is implemented as a Singleton.
  #
  # search : a search.rb object, that contains all registered accounts and items
  #
  ##
  class System
    include Singleton

    # Search where active items (see Item), users (see User) and
    # organisations (see Organisation) are registered
    attr_accessor :search

    def initialize
      @search = Search.new
    end
  end
end
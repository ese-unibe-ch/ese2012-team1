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
    attr_accessor :search

    def initialize
      @search = Search.new
    end
  end
end
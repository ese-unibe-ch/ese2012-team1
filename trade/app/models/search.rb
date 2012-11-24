require_relative('../helpers/HTML_constructor')
require 'rubygems'
require 'require_relative'
require_relative '../models/search_result'
require_relative '../models/search_item'

class Search
  attr_accessor :items

  def initialize
    self.items = Array.new
  end

  def find(search_string)
    result = SearchResult.new
    result.pattern = search_string

    items.each do |item|
      item.symbol_methods.each_with_index do |symbol_method, index|
        if item.item.send(symbol_method).include?(search_string)
          result.add(item, index+1)
          break
        end
      end
    end

    result
  end

  def register(search_item)
    items.push(search_item)
  end

  def unregister(to_be_unregistered)
    self.items = self.items.delete_if { |search_item| search_item.item == to_be_unregistered }
  end
end
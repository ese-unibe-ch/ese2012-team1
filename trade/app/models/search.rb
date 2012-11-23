class Search
  attr_accessor :items

  class SearchResult
    attr_accessor :result, :pattern

    def initialize
      self.result = Hash.new
    end

    def add(item, name)
      unless result[name]
        self.result[name] = Array.new
      end

      self.result[name].push(item)
    end

    def get(name)
      fail "There is no result for \'#{name}\'" unless self.found?(name)

      self.result[name]
    end

    def found?(name)
      result.member?(name)
    end

    def empty?
      self.result.empty?
    end

    def size
      self.result.size
    end
  end

  class SearchItem
    attr_accessor :item, :symbol_methods, :name

    def self.create(item, name, symbol_methods)
      search_item = SearchItem.new
      search_item.item = item
      search_item.name = name
      search_item.symbol_methods = symbol_methods

      search_item
    end
  end

  def initialize
    self.items = Array.new
  end

  def find(search_string)
    result = SearchResult.new
    result.pattern = search_string

    items.each do |item|
      item.symbol_methods.each do |symbol_method|
        if item.item.send(symbol_method).include?(search_string)
          result.add(item.item, item.name)
          break
        end
      end
    end

    result
  end

  def register(to_be_searched, name, methods)
    items.push(SearchItem.create(to_be_searched, name, methods))
  end

  def unregister(to_be_unregistered)
    self.items = self.items.delete_if { |search_item| search_item.item == to_be_unregistered }
  end
end
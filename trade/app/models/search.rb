class Search
  attr_accessor :items

  @item
  @params

  def initialize
    self.items = Array.new
    @item = nil
    @params = Array.new
  end

  def find(search_string)
    result = Array.new

    unless (@item.nil?)
      @params.each do |symbol_method|
        if @item.send(symbol_method).include?(search_string)
          result.push(@item)
          break
        end
      end
    end

    Array.new
  end

  def register(to_be_searched, methods)
    @item = to_be_searched
    @params = methods
  end
end
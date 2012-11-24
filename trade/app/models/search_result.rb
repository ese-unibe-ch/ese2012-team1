class SearchResult
  attr_accessor :result, :pattern

  def initialize
    self.result = Hash.new
  end

  def add(item, priority)
    unless result[item.name]
      self.result[item.name] = Array.new
    end

    self.result[item.name].push({ :item => item, :priority => priority })
  end

  def get(name)
    fail "There is no result for \'#{name}\'" unless self.found?(name)

    self.result[name].collect{ |item| item[:item].item }
  end

  def sort!(user_id)
    self.result.each do |name, items|
      items.sort! do |a, b|
        [a[:item].priority_of_user(user_id), a[:priority]] <=> [b[:item].priority_of_user(user_id), b[:priority]]
      end
    end

    self
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

class Navigation
  attr_accessor :navigation, :selected

  def initialize
    self.navigation = Array.new
    self.selected = 1
  end

  def self.create(name, direct_to)
    fail "Can't have same name twice" if navigation.member?(name)

    self.navigation.push({:name => name, :direct_to => direct_to, :subnavigation => Navigation.new})
  end

  def add_navigation(name, direct_to)
    fail "Can't have same name twice" if navigation.member?(name)

    self.navigation.push({:name => name, :direct_to => direct_to, :subnavigation => Navigation.new})
  end

  def add_subnavigation(subname, direct_to)
    self.navigation[self.selected][:subnavigation].add_navigation(subname, direct_to)
  end

  def direct_to
    if (self.navigation[self.selected][:subnavigation].empty?)
      return self.navigation[self.selected][:direct_to]
    else
      return self.navigation[self.selected][:subnavigation].direct_to
    end
  end

  def direct_to_by_index(number)
    "Navigation does not exist" if (self.navigation.size < number.to_i)

    if (self.navigation[number-1][:subnavigation].empty?)
      return self.navigation[number-1][:direct_to]
    else
      return self.navigation[number-1][:subnavigation].direct_to
    end
  end

  def name
    self.navigation[self.selected][:name]
  end

  def select(index)
    "Navigation does not exist" if (self.navigation.size < index.to_i)

    self.selected = index.to_i-1
  end

  def select_by_name(name)
    index = self.navigation.index {|navi| navi[:name] == name }

    fail "#{name} is no navigation point" if (index.nil?)

    self.selected = index
  end

  def subnavigation
    self.navigation[self.selected][:subnavigation]
  end

  def empty?
    self.navigation.size == 0
  end

  # travers do |name, direct_to, index, selected

  def travers
    self.navigation.each_with_index do |navigations, index|
      yield navigations[:name], self.direct_to_by_index(index+1), index+1, (self.selected == index)
    end
  end

  def travers_subnavigation
    self.navigation[self.selected][:subnavigation].travers do |name, direct_to, index, selected|
      yield name, direct_to, index, selected
    end
  end

  def show
    self.travers do |name, direct_to, index, selected|
      puts "#{name} => #{direct_to}"

      self.navigation[index-1][:subnavigation].travers do |name, direct_to, index, selected|
        puts "  #{name} => #{direct_to}"
      end
    end
  end
end
module Helpers

  class Navigation
    attr_accessor :navigation, :selected

    def initialize
      self.navigation = Array.new
      self.selected = 1
    end

    def add_navigation(name, direct_to)
      fail "Can't have same name twice" if navigation.member?(name)

      self.navigation.push({:name => name, :direct_to => direct_to, :subnavigation => Navigation.new})
    end

    def add_subnavigation(subname, direct_to)
      self.navigation[self.selected][:subnavigation].add_navigation(subname, direct_to)
    end

    def direct_to
      if (self.navigation[self.selected][:direct_to])
        return self.navigation[self.selected][:direct_to]
      else
        return self.navigation[self.selected][:subnavigation].direct_to
      end
    end

    def direct_to_by_index(number)
      "Navigation does not exist" if (self.navigation.size < number.to_i)
      "Navigation does not exist" if (number.to_i < 1)

      if (self.navigation[number-1][:direct_to])
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
      "Navigation does not exist" if index.to_i < 1

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
    def travers(selected)
      selected = convert_to_number(selected) unless selected.to_s.is_positive_integer?

      self.navigation.each_with_index do |navigations, index|
        yield navigations[:name], self.direct_to_by_index(index+1), index+1, (selected == index)
      end
    end

    def convert_to_number(selected)
      index = self.navigation.index {|navi| navi[:name] == selected }

      fail "#{selected} is no navigation point" if (index.nil?)

      index
    end

    def travers_subnavigation(selected)
      selected = convert_to_number(selected) unless selected.to_s.is_positive_integer?

      self.navigation[selected][:subnavigation].travers(selected) do |name, direct_to, index, selected|
        yield name, direct_to, index, selected
      end
    end

  end

end
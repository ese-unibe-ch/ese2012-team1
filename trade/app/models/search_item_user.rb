require 'rubygems'
require 'require_relative'

require_relative 'search_item'

class SearchItemUser < SearchItem
  def part_of?(user_id)
    self.item.id == user_id
  end
end
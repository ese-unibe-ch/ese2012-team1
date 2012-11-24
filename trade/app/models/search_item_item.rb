require 'rubygems'
require 'require_relative'

require_relative 'search_item'
require_relative 'system'

class SearchItemItem < SearchItem

  def part_of?(user_id)
    self.item.owner.id == user_id
  end
end
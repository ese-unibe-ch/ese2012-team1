require 'rubygems'
require 'require_relative'

require_relative 'search_item'
require_relative 'system'

class SearchItemOrganisation < SearchItem

  def part_of?(user_id)
    user = System.instance.fetch_account(user_id)

    self.item.is_member?(user)
  end
end
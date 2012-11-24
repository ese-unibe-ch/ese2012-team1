module Models
  class SearchItemItem < SearchItem

    def part_of?(user_id)
      self.item.owner.id == user_id
    end
  end
end
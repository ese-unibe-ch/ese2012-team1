module Models
  class SearchItemUser < SearchItem
    def part_of?(user_id)
      self.item.id == user_id
    end
  end
end
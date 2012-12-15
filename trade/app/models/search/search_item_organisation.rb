module Models
  class SearchItemOrganisation < SearchItem

    def part_of?(user_id)
      user = DAOAccount.instance.fetch_account(user_id)

      self.item.is_member?(user)
    end
  end
end
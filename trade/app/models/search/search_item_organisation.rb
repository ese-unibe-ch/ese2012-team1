module Models
  ##
  #
  # A SearchItem for Organisation (see SearchItem for more information)
  #
  ##
  class SearchItemOrganisation < SearchItem

  ##
  #
  # A user is part of this SearchItemOrganisation
  # if he's member of the associated
  # Organisation
  #
  # Returns true if user is member
  # of the associated Organisation, false
  # otherwise.
  #
  # +user_id+:: id of the user to be checked
  #
  ###

  def part_of?(user_id)
      user = DAOAccount.instance.fetch_account(user_id)

      self.item.is_member?(user)
    end
  end
end
module Models
  ##
  #
  # A SearchItem for User (see SearchItem for more information)
  #
  ##

  class SearchItemUser < SearchItem
  ##
  #
  # A user is part of this SearchItemUser
  # if he is the User associated with
  # this SearchItemUser.
  #
  # Returns true if user is the
  # user, false otherwise.
  #
  # +user_id+:: id of the user to be checked
  #
  ##
  def part_of?(user_id)
      self.item.id == user_id
    end
  end
end
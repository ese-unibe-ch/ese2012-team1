module Models
  ##
  #
  # A SearchItem for Item (see SearchItem for more information)
  #
  ##

  class SearchItemItem < SearchItem

    ##
    #
    # A user is part of this SearchItemItem
    # if he owns the +item+ associated
    # with it.
    #
    # Returns true if user it the owner
    # of the associated +item+, false
    # otherwise.
    #
    # +user_id+:: id of the user to be checked
    #
    ##

    def part_of?(user_id)
      self.item.owner.id == user_id
    end
  end
end
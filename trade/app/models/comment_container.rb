module Models
  ##
  #
  #CommentContainer can hold multiple comments.
  #
  #It has a description and an avatar.
  #Implementations of accounts may add a new item to the system with a name and a price;
  #  the item is originally inactive.
  #Implementations of accounts may own certain items
  #Implementations of accounts may buy active items of another account
  #  (inactive items can't be bought). If an implementation of account buys an item,
  #  it becomes the owner; credits are transferred accordingly; immediately after
  #  the trade, the item is inactive. The transaction
  #  fails if the buyer has not enough credits.
  #
  # generate getter and setter
  #
  ##
  class CommentContainer
    attr_accessor :depth

    def initialize
      @comments = Array.new
      self.depth = 0
    end

    ##
    #
    # Returns the count of direct children
    #
    ##
    def size
      @comments.size
    end

    ##
    #
    # Adds a new child to the container. Assigns his depth
    # plus one as depth to the new child.
    #
    # You can not add nil as new child.
    #
    ##
    def add(comment)
      fail "Comment should not be nil" if (comment.nil?)

      @comments.push(comment)
      comment.depth = self.depth+1
    end

    ##
    #
    # Travers over all comments by calling #collect and iterating over each
    # element.
    #
    # Example to print all comments:
    # container.travers{ |comment| puts comment }
    #
    ##
    def travers
      self.collect.each do |comment|
        yield comment
      end
    end

    ##
    #
    # Gets comment with the specific nr
    #
    ##
    def get(comment_nr)
      self.collect.each do |comment|
        return comment if (comment.nr == comment_nr.to_i)
      end
    end

    ##
    #
    # Collects all children comments and returns them ordered in
    # the way they were added. Simply skips all CommentContainers.
    #
    ##
    def collect
      collected_comments = Array.new

      @comments.each{ |comment| comment.collect.each { |inner_comment| collected_comments.push(inner_comment) } }

      collected_comments
    end
  end
end
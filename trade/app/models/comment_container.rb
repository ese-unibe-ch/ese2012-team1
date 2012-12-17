module Models
  ##
  #
  # A CommentContainer can have comments on itself. If there are multiple
  # comments on the same CommentContainer, the container is responsible
  # to sort them by adding date. The oldest added comment is first and the
  # newest added comment is the last. A container also knows how many direct
  # comments on it there are.
  #
  ##
  class CommentContainer
    #Shows the depth of the comment container. The root container has
    #depth zero.
    attr_accessor :depth
    @comments

    ##
    #
    # The depth is important in the views, it defines how much a comment
    # is indented. Per default this is 0.
    # @comments is an array which contains all direct comments
    #
    ##
    def initialize
      @comments = Array.new
      self.depth = 0
    end #:nodoc

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
    # === Parameters
    #
    # +comment+:: comment to be added (Can't be nil)
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
    # element
    #
    # === Example
    #
    #   container.travers{ |comment| puts comment }
    #
    ##
    def travers
      self.collect.each do |comment|
        yield comment
      end
    end

    ##
    #
    # Gets comment by his unique nr (see Comment). Returns
    # nil if comment with this number does not
    # exist.
    #
    # === Parameters
    #
    # +comment_nr+:: Number of comment to get
    ##
    def get(comment_nr)
      fail "must be a positive number" unless comment_nr.to_s.is_positive_integer?

      self.collect.each do |comment|
        return comment if (comment.nr == comment_nr.to_i)
      end

      nil
    end

    ##
    #
    # Collects all children comments and returns them as array
    # ordered in the way they were added.
    #
    ##
    def collect
      collected_comments = Array.new

      @comments.each{ |comment| comment.collect.each { |inner_comment| collected_comments.push(inner_comment) } }

      collected_comments
    end
  end
end
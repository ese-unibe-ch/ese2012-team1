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
  # the way the were added. Simply skips all CommentContainers.
  #
  ##

  def collect
    collected_comments = Array.new

    @comments.each{ |comment| comment.collect.each { |inner_comment| collected_comments.push(inner_comment) } }

    collected_comments
  end
end
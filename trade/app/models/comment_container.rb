class CommentContainer
  attr_accessor :depth

  def initialize
    @comments = Array.new
    self.depth = 0
  end

  def size?
    @comments.size
  end

  def add(comment)
    fail "Comment should not be nil" if (comment.nil?)

    @comments.push(comment)
    comment.depth = self.depth+1
  end

  def travers
    self.collect.each do |comment|
      yield comment
    end
  end

  def collect
    collected_comments = Array.new

    @comments.each{ |comment| comment.collect.each { |inner_comment| collected_comments.push(inner_comment) } }

    collected_comments
  end
end
require "rubygems"
require "require_relative"

require_relative "comment_container"

class Comment < CommentContainer
  attr_accessor :comment, :creator, :header, :nr, :date_stamp

  @@unique_nr = 0

  ##
  #
  # Creates a comment by saving his creator
  # and the comment itself
  #
  ##

  def self.create(creator, header, comment_text)
    comment = self.new

    comment.header = header
    comment.comment = comment_text
    comment.creator = creator
    comment.date_stamp = Time.now.inspect

    comment.nr = @@unique_nr
    @@unique_nr += 1

    comment
  end

  ##
  #
  # Collects itself and all children comments.
  #
  ##

  def collect
    collected_comments = Array.new
    collected_comments.push(self)

    @comments.each{ |comment| comment.collect.each { |inner_comment| collected_comments.push(inner_comment) } }

    collected_comments
  end

  def to_s
    " " * (depth-1) + "#{self.creator} commented \'#{self.comment}\'"
  end
end
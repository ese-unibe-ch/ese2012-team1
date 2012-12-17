module Models
  ##
  #
  #  A Comment is written by a user. It holds the text, the
  #  subject, the date and its creator.
  #
  #  Comment is a CommentContainer.
  #  With this inheritance it is possible
  #  to make a comment on a comment.
  #
  ##

  class Comment < CommentContainer

    # Content itself (String)
    attr_accessor :comment
    # Writer of the comment (Account)
    attr_accessor :creator
    # Title of the comment (String)
    attr_accessor :header
    # Unique number of the comment (Integer)
    attr_reader :nr
    # Date when the comment was written (Time)
    attr_accessor :date_stamp

    @@unique_nr = 0

    def initialize
      @nr = @@unique_nr
      @@unique_nr += 1
    end

    ##
    #
    # Creates a comment by saving his creator
    # the comment, the creation time, his unique
    # number and subject.
    #
    # Date and unique number are provided by
    # this method while the other informations
    # have to be passed as parameters.
    #
    # === Parameters
    #
    # +creator+:: account who created this comment
    # +header+:: title
    # +comment_text+:: the actual message
    #
    ##
    def self.create(creator, header, comment_text)
      comment = self.new

      comment.header = header
      comment.comment = comment_text
      comment.creator = creator
      comment.date_stamp = Time.now

      comment
    end

    ##
    #
    # Returns an array including itself and all children comments.
    #
    ##

    def collect
      collected_comments = Array.new
      collected_comments.push(self)

      @comments.each{ |comment| comment.collect.each { |inner_comment| collected_comments.push(inner_comment) } }

      collected_comments
    end

    ##
    #
    # String representation of a comment
    #
    ##
    def to_s
      " " * (depth-1) + "#{self.creator} commented \'#{self.comment}\'"
    end
  end
end
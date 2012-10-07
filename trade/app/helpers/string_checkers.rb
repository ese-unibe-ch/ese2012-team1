##
#
# Does add some features to the string class.
#
##

class String

  ##
  #
  # Check if string is an email
  #
  ##

  def is_email?
    self =~ /[A-Za-z123456789._-]+@[A-Z.a-z123456789-]+\.[a-z]+$/
  end
end
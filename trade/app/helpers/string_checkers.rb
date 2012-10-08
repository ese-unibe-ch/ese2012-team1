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
    return false unless (self.include?('@'))
    parts = (self.split('@', 2))
    local_part = parts[0]
    domain_part = parts[1]
    return false if (domain_part.include?('@'))

    eval_local_part = local_part =~ /[A-Za-z123456789._-]+/
    eval_domain_part = domain_part =~ /[A-Z.a-z123456789-]+\.[a-z]+$/

    eval_domain_part && eval_local_part
  end

end
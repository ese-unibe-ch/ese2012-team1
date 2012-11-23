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

    eval_local_part = local_part =~ /^[A-Za-z0123456789._-]+$/
    eval_domain_part =  domain_part =~ /^[A-Z.a-z0123456789-]+\.[a-z]+$/

    eval_domain_part && eval_local_part
  end

##
#
# Checks if it is a strong password meaning
# 1) At least six characters long
# 2) Contains at least one number, one small letter and one capital letter
# 3) Contains only numbers, capital and small letters
#
##

  def is_strong_password?
    if self.match(/[^a-zA-Z1-9]/)
        false
    elsif self.length < 6
        false
    elsif self.match(/^[A-Z]+$/)
        false
    elsif self.match(/^[a-z]+$/)
        false
    elsif self.match(/^\d+$/)
        false
    elsif self.match(/^([a-zA-Z])+$/) || self.match(/^([a-z]|\d)+$/) || self.match(/^([A-Z]|\d)+$/)
        false
    else
        true
    end
  end

  ##
  #
  # Surrounds given part of string with <strong></strong> html
  # tags.
  #
  # Example:
  # string = "hold"
  # string.boldify("old") # h<strong>old</strong>
  #
  ##

  def boldify(string)
    self.gsub(string, "<strong>#{string}</strong>")
  end

end
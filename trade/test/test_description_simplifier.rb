require "test/unit"

#####
#
# Class that should help you to write more readable tests
#
# You can now write tests in this way
#
# +should "have a name" do
#   #Test if it has a name
# end
#
# shouldnt "have a name" do
#   #Test if it has not a name
# end
#
# it "should send message" do
#   #Test if it does send message
# end
#
# test "get name" do
#   #Tests if it gets his name
# end+
#
###

class Test::Unit::TestCase

  def self.should(name, &block)
    define_method(test_name(name), &block)
  end

  # Sets alias for should so you can write your tests
  # the way you like
  class << self
    alias_method :test, :should
    alias_method :it, :should
    alias_method :shouldnt, :should
  end

  # Transforms a name into a symbol starting with
  # test\__and_so_on_

  def self.test_name(name)
    "test_#{replace_spaces_with_underscore(replace_capital_letters(name))}".to_sym
  end

  # Replaces all spaces with underscores

  def self.replace_spaces_with_underscore(name)
    name.gsub(/\s+/, '_')
  end

  # Replaces all capital letters with whitespaces

  def self.replace_capital_letters(name)
    name.gsub(/\W+/, ' ')
  end
end
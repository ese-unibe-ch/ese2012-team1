require "test/unit"

class Test::Unit::TestCase

  def self.should(name, &block)
    define_method(test_name(name), &block)
  end

  class << self
    alias_method :test, :should
    alias_method :it, :should
    alias_method :shouldnot, :should
  end

  def self.test_name(name)
    "test_#{replace_whitespaces(remove_capital_letters(name))}".to_sym
  end

  def self.replace_whitespaces(name)
    name.gsub(/\s+/, '_')
  end

  def self.remove_capital_letters(name)
    name.gsub(/\W+/, ' ')
  end
end
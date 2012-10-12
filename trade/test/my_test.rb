require "test/unit"
require 'rubygems'
require 'require_relative'
require_relative('../app/models/system')
require_relative('../app/models/user')
require_relative('../app/models/item')

class MyTest < Test::Unit::TestCase

  def test_singleton_initialisation
    system_a = Models::System.instance
    system_b = Models::System.instance
    assert(system_a == system_b, "Two instances should be the same")
  end
  def test_method
    a = Models::System.instance
    a.get_users.store("test","test")
    assert(a.get_users.has_key?("test") )
  end
end
require 'test/unit'
require 'rubygems'
require 'require_relative'
require_relative('../app/models/system')

class SystemTest < Test::Unit::TestCase

  def test_item_initialisation
    system_a = Models::System.instance
    system_b = Models::System.instance
    assert(system_a == system_b, "Two instances should be the same")

  end

end
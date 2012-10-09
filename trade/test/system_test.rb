require 'test/unit'
require 'rubygems'
require 'require_relative'
require_relative('../app/models/system')
require_relative('../app/models/user')
require_relative('../app/models/item')
class SystemTest < Test::Unit::TestCase

  @momo
  @beppo

  def setup
    @momo = Models::User.created("Momo",    "zeit",     "momo@mail.ch",   "Denn Zeit ist Leben",  "../images/users/default_avatar.png")
    @beppo = Models::User.created("Beppo",  "strasse",  "beppo@gmail.ch", "Schritt für Schritt", "../images/users/default_avatar.png")
  end

  def teardown
    @momo.clear
    @beppo.clear
  end

  def test_singleton_initialisation
    system_a = Models::System.instance
    system_b = Models::System.instance
    assert(system_a == system_b, "Two instances should be the same")
  end

  def test_should_add_user
    system = Models::System.instance
    system.add_user(@momo)
    system.add_user(@beppo)
    assert(system.users.size == 2, "there should be 2 users, but there were #{system.users.size} user(s).")
  end

end
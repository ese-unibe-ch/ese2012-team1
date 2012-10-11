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
    @kassiopeia = Models::User.created("Kassiopeia", "panzer", "kassiopeia@hotmail.ch", "*schweig*", "../images/users/default_avatar.png" )
  end

  def teardown
    @momo.clear
    @beppo.clear
  end


  #---- Singleton -----------------
  def test_singleton_initialisation
    system_a = Models::System.instance
    system_b = Models::System.instance
    assert(system_a == system_b, "Two instances should be the same")
  end

  #---- User ----------------------

  def test_should_add_user
    system = Models::System.instance
    system.add_user(@momo)
    system.add_user(@beppo)
    assert(system.users.size == 2, "there should be 2 users, but there were #{system.users.size} user(s).")
  end

  def test_should_fetch_user
    system = Models::System.instance
    system.add_user(@momo)
    system.add_user(@beppo)
    system.add_user(@kassiopeia)

    assert(system.fetch_user("beppo@gmail.ch")== @beppo, "User should be Beppo, but was #{system.fetch_user("beppo@gmail.ch")}")
    assert(system.fetch_user("momo@mail.ch")== @momo, "User should be Momo, but was #{system.fetch_user("momo@mail.ch")}")
  end

  def test_should_remove_user
    system = Models::System.instance
    system.add_user(@momo)
    system.add_user(@beppo)
    system.add_user(@kassiopeia)

    system.remove_user("kassiopeia@hotmail.ch")
    assert(system.users.size == 2, "There should be 2 users left, but there were #{system.users.size}")
    assert(system.users.values == [@momo, @beppo])

    system.remove_user("beppo@gmail.ch")
    system.remove_user("momo@mail.ch")

    assert(system.users.size == 2, "There should be no users left, but there were still #{system.users.size} users")
  end

  def test_should_fetch_all_but_one_user
    system = Models::System.instance
    system.add_user(@momo)
    system.add_user(@beppo)

    others = system.fetch_all_users_but("momo@mail.ch")
    assert(system.fetch_all_users_but("momo@mail.ch").size == 1, "Only one should remain, but there were #{system.fetch_all_users_but("momo@")}")
    assert( others == [@beppo], "Beppo should be left, but instead: #{others}")

    others = system.fetch_all_users_but("beppo@gmail.ch")
    assert(system.fetch_all_users_but("beppo@gmail.ch").size == 1, "Only one should remain, but there were #{system.fetch_all_users_but("momo@")}")
    assert( others == [@beppo], "Momo should be left, but instead: #{others}")

    system.add_user(@kassiopeia)
    others = system.fetch_all_users_but("momo@mail.ch")
    assert(system.fetch_all_users_but("momo@mail.ch").size == 2, "Two should remain, but there were #{system.fetch_all_users_but("momo@")}")
    assert( others == [@beppo], "Beppo and Momo should be left, but instead: #{others}")
  end

  # ---- Item -------------------------------
end
require 'test/unit'
require 'rubygems'
require 'require_relative'
require_relative('../app/models/system')
require_relative('../app/models/user')
require_relative('../app/models/item')

class SystemTest < Test::Unit::TestCase


  @momo
  @beppo
  @sand
  @time
  @curly_hair
  @broom

  def setup
    #set up some users
    @momo = Models::User.created("Momo",    "zeit",     "momo@mail.ch",   "Denn Zeit ist Leben",  "../images/users/default_avatar.png")
    @beppo = Models::User.created("Beppo",  "strasse",  "beppo@gmail.ch", "Schritt für Schritt", "../images/users/default_avatar.png")
    @cassiopeia = Models::User.created("Cassiopeia", "panzer", "kassiopeia@hotmail.ch", "*schweig*", "../images/users/default_avatar.png" )
    #set up some items
    @sand = Models::Item.created("Sand", @momo, 12)
    @time = Models::Item.created("Time", @cassiopeia, 200)
    @curly_hair = Models::Item.created("curly_hair", @momo, 25)
    @broom = Models::Item.created("Broom", @beppo, 15)
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
    system.add_user(@cassiopeia)

    assert(system.fetch_user("beppo@gmail.ch")== @beppo, "User should be Beppo, but was #{system.fetch_user("beppo@gmail.ch")}")
    assert(system.fetch_user("momo@mail.ch")== @momo, "User should be Momo, but was #{system.fetch_user("momo@mail.ch")}")
  end

  def test_should_remove_user
    system = Models::System.instance
    system.add_user(@momo)
    system.add_user(@beppo)
    system.add_user(@cassiopeia)

    system.remove_user("cassiopeia@hotmail.ch")
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

  # --------item-------------------------------------------------------------

  def test_should_add_item
    system = Models::System.instance
    assert(system.items.size == 0, "there should be no items in the system, but there were #{system.items.size} items")

    system.add_item(@time)
    assert(system.items.size == 1, "there should be one item in the system, but there were #{system.items.size} items")
    assert(@time.id == 0)

    system.add_item(@sand)
    system.add_item(@curly_hair)
    assert(system.items.size == 3, "there should be three items in the system, but there were #{system.items.size} items")
    assert(@time.id == 0 and @sand.id == 1 and @curly_hair.id ==2)
  end

  def test_should_fetch_item
    system = Models::System.instance
    system.add_item(@time)
    system.add_item(@sand)
    system.add_item(@curly_hair)

    assert(system.fetch_item("Time")==@time, "Fetched item should be Time, but was #{system.fetch_item("Time")}")
  end

  def test_should_fetch_item_of_user
    system = Models::System.instance
    system.add_item(@time)
    system.add_item(@sand)
    system.add_item(@curly_hair)

    items_cassiopeia = system.fetch_items_of("cassiopeia@hotmail.ch")
    items_momo = system.fetch_items_of("momo@mail.ch")
    assert(items_cassiopeia.value?(@time), "Cassiopeia should have Time, but has #{items_kassiopeia}")
    assert(items_momo.value?(@sand), "Momo should have Sand, but has #{items_momo}")
    assert(items_momo.value?(@curly_hair), "Momo should have Curly Hair, but has #{items_momo}")


  end

  def test_should_fetch_all_items_but_of_user
    system = Models::System.instance
    system.add_user(@momo)
    system.add_user(@beppo)
    system.add_user(@cassiopeia)
    system.add_item(@time)
    system.add_item(@sand)
    system.add_item(@curly_hair)
    system.add_item(@broom)

    remaining =  system.fetch_all_items_but_of("Momo")
    assert(remaining.value.include?(@time))
    assert(remaining.value.include?(@broom))
    assert(remaining.size == 2, "There should be 2 items left, but there are #{remaining.to_s}.")


  end

  def test_should_remove_item
    system = Models::System.instance
    system.add_item(@time)
    system.add_item(@sand)
    system.add_item(@curly_hair)
    system.add_item(@broom)

    system.remove_item(@broom)
    assert(system.items.include?(@broom.get_id), "Broom should no longer be in items.")
    assert(system.items.size == 3)

    system.remove_item(@sand)
    system.remove_item(@curly_hair)
    system.remove_item(@time)
    assert(system.items.size == 0)
  end

  # ---- organisation ---------------------

  # Adds an item to the system and increments the id counter for items.
  def add_organisation(org)
    fail "No organisation" if (user == nil)
    organisation.store(org.get_name, org)
  end

  # Returns the organisation with associated name.
  def fetch_organisation(org_name)
    fail "No such organisation name" if self.organisation.contains(org_name)
    self.organisation.fetch(org_name)
  end

  # Returns a list of all the users organisations
  def fetch_organisations_of(user_email)
    fail "No such user email" if self.users.contains(user_email)
    user = self.fetch_user(user_email)
    self.organisation.each{|org_name, org| org.is_member?(user)}
  end

  # Removes an organisation from the system.
  def remove_organisation(org_name)
    fail "No such organisation name found" if self.organisation.contains(org_name)
    organisations.delete(org_name)
  end

end
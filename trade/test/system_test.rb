require 'test/unit'
require 'rubygems'
require 'require_relative'
require_relative('../app/models/system')
require_relative('../app/models/user')
require_relative('../app/models/item')
require_relative('../app/models/organisation')

class MockItem
   attr_accessor :owner, :id

  def initialize
    self.owner = MockUser.create("momo@mail.ch")
    self.id = nil
  end

  def self.create(owner_mail)
    item = self.new
    item.owner = owner_mail
    item
  end

  def to_s
    "#{self.id}=>#{self.owner}"
  end
end

class MockOrganisation
  def get_name
    "Meister Hora Club"
  end

  def is_member?(user_email)
    true
  end
end


class MockUser
  attr_accessor :email

  def initialize
    self.email = "mail@mail.ch"
  end

  def self.create(*args)
    user = self.new
    user.email = args.size == 1 ? args[0] : "mail@mail.ch"
    user
  end

  def to_s
    "#{self.email}"
  end
end

class SystemTest < Test::Unit::TestCase
  def add_users
    system = Models::System.instance

    users = { :momo => MockUser.create("momo@mail.ch"),
            :beppo => MockUser.create("beppo@mail.ch"),
            :kassiopeia => MockUser.create("kassiopeia@mail.ch") }

    system.add_user(users[:momo])
    system.add_user(users[:beppo])
    system.add_user(users[:kassiopeia])

    users
  end

  def add_items(users)
    system = Models::System.instance

    items = { :curly_hair => MockItem.create(users[:momo]),
              :sand => MockItem.create(users[:momo]),
              :broom => MockItem.create(users[:beppo]),
              :time => MockItem.create(users[:kassiopeia]) }

    system.add_item(items[:curly_hair])
    system.add_item(items[:sand])
    system.add_item(items[:broom])
    system.add_item(items[:time])

    items
  end

  def teardown
    Models::System.instance.users = Hash.new
    Models::System.instance.items = Hash.new
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
    assert(system.users.size == 0, "there should be 3 users, but there were #{system.users.size} user(s): #{system.users}")
    mock_user = MockUser.new
    system.add_user(mock_user)
    assert(system.users.size == 1, "there should be 1 user, but there were #{system.users.size} user(s): #{system.users}")
  end

  def test_should_fail_if_adding_user_twice
    system = Models::System.instance
    user0 = MockUser.new
    system.add_user(user0)
    assert(system.users.member?(user0.email), "User0 should already be added to the system")
    assert_raise(RuntimeError) { Models::System.instance.add_user(user0)}
  end

  def test_should_fetch_user
    system = Models::System.instance

    users = add_users

    assert(system.fetch_user("beppo@mail.ch")== users[:beppo], "User should be Beppo, but was #{system.fetch_user("beppo@mail.ch")}")
    assert(system.fetch_user("momo@mail.ch")== users[:momo], "User should be Momo, but was #{system.fetch_user("momo@mail.ch")}")
  end

  def test_should_remove_user
    system = Models::System.instance

    users = add_users

    system.remove_user(users[:kassiopeia].email)
    assert(system.users.size == 2, "There should be 2 users left, but there were #{system.users.size}")
    assert(   system.users.values == [users[:momo], users[:beppo]] ||
              system.users.values == [users[:beppo], users[:momo]])

    system.remove_user("beppo@mail.ch")
    system.remove_user("momo@mail.ch")

    assert(system.users.size == 0, "There should be no users left, but there were still #{system.users.size} users")
  end

  def test_should_fetch_all_but_one_user
    system = Models::System.instance

    beppo = MockUser.create("beppo@mail.ch")
    momo = MockUser.create("momo@mail.ch")

    system.add_user(momo)
    system.add_user(beppo)

    others = system.fetch_all_users_but("momo@mail.ch")
    assert(others.size == 1, "Only one should remain, but there were #{others.size}")
    assert( others == [beppo], "Beppo should be left, but instead: #{others}")

    others = system.fetch_all_users_but("beppo@mail.ch")
    assert(others.size == 1, "Only one should remain, but there were #{others}")
    assert( others == [momo], "Momo should be left, but instead: #{others}")

    system.add_user(MockUser.create("kassiopeia@mail.ch"))

    others = system.fetch_all_users_but("kassiopeia@mail.ch")
    assert(others.size == 2, "Two should remain, but there were #{others}")
    assert( others == [momo, beppo] || others == [beppo, momo], "Beppo and Momo should be left, but instead: #{others}")
  end

  # --------item-------------------------------------------------------------

  def test_should_add_item
    system = Models::System.instance
    assert(system.items.size == 0, "there should be no items in the system, but there were #{system.items.size} items")

    #This is more a test for item! assert(@time.id == nil, "Unless an item is added to the system, its id should be nil, but was #{@time.id}")
    mock_item0 = MockItem.new
    system.add_item(mock_item0)
    assert(system.items.size == 1, "there should be one item in the system, but there were #{system.items.size} items")
    assert(mock_item0.id == 0, "The id of the first item should be 0 but it was #{@time.id}")

    mock_item1 = MockItem.new
    system.add_item(mock_item1)
    assert(system.items.size == 2, "there should be three items in the system, but there were #{system.items.size} items")
    assert(mock_item1.id == 1, "The id of the second item should be 1 but was #{@sand.id}")

    mock_item2 = MockItem.new
    system.add_item(mock_item2)
    assert(system.items.size == 3, "there should be three items in the system, but there were #{system.items.size} items")
    assert((mock_item0.id == 0) && (mock_item1.id == 1) && (mock_item2.id ==2))
  end

  def test_should_fetch_item
    system = Models::System.instance
    items = add_items(add_users)

    fetched_item = system.fetch_item(items[:time].id)
    assert(fetched_item == items[:time], "Fetched item should be Time, but was #{fetched_item}")
  end

  def test_should_fetch_item_of_user
    system = Models::System.instance
    items = add_items(add_users)

    items_cassiopeia = system.fetch_items_of("kassiopeia@mail.ch")
    items_momo = system.fetch_items_of("momo@mail.ch")
    assert(items_cassiopeia.include?(items[:time]), "Kassiopeia should have Time, but has #{items_cassiopeia}")
    assert(items_momo.size == 2, "Items size should be 2 but was #{items_momo.size}")
    assert(items_momo.include?(items[:sand]), "Momo should have Sand, but has #{items_momo}")
    assert(items_momo.include?(items[:curly_hair]), "Momo should have Curly Hair, but has #{items_momo}")
  end

  def test_should_fetch_all_items_but_of_user
    system = Models::System.instance

    users = add_users
    items = add_items(users)

    remaining =  system.fetch_all_items_but_of(users[:momo].email)
    assert(remaining.values.include?(items[:broom]))
    assert(remaining.values.include?(items[:time]))
    assert(remaining.size == 2, "There should be 2 items left, but there are #{remaining.to_s}.")

  end

  def test_should_remove_item
    system = Models::System.instance

    items = add_items(add_users)


    assert(system.items.size == 4, "Should have 4 items but where #{system.items.size}")

    system.remove_item(items[:broom])
    assert(! system.items.include?(items[:broom].id), "Broom should no longer be in items: #{items}")
    assert(system.items.size == 3, "Should have 3 items but where #{system.items.size}")

    system.remove_item(items[:sand])
    system.remove_item(items[:curly_hair])
    system.remove_item(items[:time])
    assert(system.items.size == 0)
  end

  # ---- organisation ---------------------

  def test_should_add_organisation
    system = Models::System.instance
    organisation = MockOrganisation.new
    system.add_organisation(organisation)
    assert(system.organisation.size == 1, "There should be exactly one organisation, but there are #{system.organisation.size}")
  end

  def test_should_fetch_org
    system = Models::System.instance
    organisation = MockOrganisation.new
    system.add_organisation(organisation)
    assert(system.fetch_organisation("Meister Hora Club") == organisation)
  end

  # Testing only the case, that organisation has one user
  def test_should_fetch_user_of_org
    system = Models::System.instance

    add_users
    organisation = MockOrganisation.new

    system.add_organisation(organisation)
    assert(system.fetch_organisations_of("kassiopeia@mail.ch").include?(organisation.get_name))
  end

  def test_should_remove_organisation
    system = Models::System.instance

    organisation = MockOrganisation.new
    system.add_organisation(organisation)
    assert(system.organisation.include?(organisation.get_name))

    system.remove_organisation(organisation.get_name)
    assert(system.organisation.size == 0, "There should be no organisation left, but is still #{system.organisation.size}")
  end

end
require 'test/unit'
require 'rubygems'
require 'require_relative'
require_relative('../app/models/user')
require_relative('../app/models/item')

class ItemTest < Test::Unit::TestCase

  @owner

  def setup
    @owner = Models::User.created("testuser", "password", "user@mail.ch", "Hey there", "C:/bild.gif")
  end

  def teardown
    @owner.clear
  end

  #test if item is initialized correctly
  def test_item_initialisation
    item = @owner.create_item("testobject", 50)
    assert(item.get_name == "testobject", "Name should be returned")
    assert(item.get_price == 50, "Should return price")
    assert(!item.is_active?, "Should not be active")
     @owner.clear
  end

  #test for item activation
  def test_item_activation
    item = @owner.create_item("testobject", 50)
    assert(item.get_name == "testobject", "Name should be returned")
    assert(item.get_price == 50, "Should return price")
    assert(!item.is_active?, "Should not be active")
    item.to_active
    assert(item.get_name == "testobject", "Name should be returned")
    assert(item.get_price == 50, "Should return price")
    assert(item.is_active?, "Should be active now")
    @owner.clear
  end

  # test for items owner
  def test_item_owner
    item = @owner.create_item("testobject", 50)
    assert(item.get_owner == @owner, "Owner not set correctly")
    assert(item.get_owner.get_name == "testuser", "Owner not set correctly")
    @owner.clear
  end

  # test for items owner after selling
  def test_item_owner_after_selling
    old_owner = Models::User.created("Old", "password", "old@mail.ch", "i'm old", "old.gif" )
    new_owner = Models::User.created("New", "password", "new@mail.ch", "i'm new", "new.gif")
    item = old_owner.create_item("sock",10)
    assert(item.get_owner == old_owner, "Owner not set correctly")
    assert(item.get_owner.get_name == "Old", "Owner not set correctly")
    old_owner.list_items_inactive[0].to_active
    if new_owner.buy_new_item?(item)
      old_owner.remove_item(item)
    end
    assert(item.get_owner == new_owner, "Owner not set correctly")
    assert(item.get_owner.get_name == "New", "Owner not set correctly")

    old_owner.clear
    new_owner.clear
  end

end
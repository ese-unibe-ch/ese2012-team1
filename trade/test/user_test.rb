def relative(path)
  File.join(File.expand_path(File.dirname(__FILE__)), path)
end
require 'test/unit'
require 'rubygems'
require 'require_relative'
require_relative('../app/models/user')
require_relative('../app/models/item')

class UserTest < Test::Unit::TestCase

  ##
  #
  # Save and clear
  #
  ##

  def test_should_remove_from_list_of_users
    owner = Models::User.created("testuser", "password")
    owner.save
    detected_user = Models::User.get_all(nil).detect{|user| user == owner}
    assert(detected_user != nil, "Should be in list")
    owner.clear
    detected_user = Models::User.get_all(nil).detect{|user| user == owner}
    assert(detected_user == nil, "Should be removed from list")
  end

  ##
  #
  # User creation
  #
  ##

  def test_should_create_user
    owner = Models::User.created("testuser", "password")
    assert(owner != nil, "Should create a test user")
  end

  def test_should_have_name
    owner = Models::User.created("testuser", "password")
    assert(owner.name == "testuser", "Should have name")
  end

  def test_should_have_password
    owner = Models::User.created("testuser", "password")
    assert(owner.password_hash != nil, "Should set password hash")
    assert(owner.password_salt != nil, "Should set password salt")
  end

  def test_should_have_description
    fail("Not yet implemented")
  end

  def test_should_have_path_to_avatar
    fail("Not yet implemented")
  end

  def test_should_have_unique_email_adresse
    fail("Not yet implemented")
  end

  def test_should_accept_password
    owner = Models::User.created("testuser", "password")
    owner.save
    assert(Models::User.login("testuser", "password"), "Should login")
    owner.clear
  end

  def test_should_not_accept_password
    owner = Models::User.created("testuser", "password")
    owner.save
    begin
      Models::User.login("testuser", "passwor")
    rescue => e
      assert(e.is_a(RuntimeError))
    end
    owner.clear
  end

  ##
  #
  # Item creation
  #
  ##

  def test_user_item_create
    owner = Models::User.created( "testuser", "password" )
    assert( owner.list_items.size == 0, "Item list length should be 0" )
    assert( owner.list_items_inactive.size == 0, "Item list inactive length should be 0" )
    owner.create_item("testobject", 10)
    assert( owner.list_items.size == 0, "Item list length should be 0" )
    assert( owner.list_items_inactive.size == 1, "Item list inactive length should be 1" )
    assert( !owner.list_items_inactive[0].is_active?, "New created item should be inactive" )
    owner.list_items_inactive[0].to_active
    assert( owner.list_items.size == 1, "Item list length should be 1" )
    assert( owner.list_items_inactive.size == 0, "Item list inactive length should be 0" )
    assert( owner.list_items[0].is_active? , "New created item should now be active" )
    assert( owner.list_items[0].to_s, "testobject, 10" )
  end

  def test_create_user
    owner = Models::User.created( "testuser", "password" )
    assert( owner.get_name == "testuser", "Name should be correct")
    assert( owner.get_credits == 100, "Credits should be 100 first")
    assert( owner.to_s == "testuser has currently 100 credits, 0 active and 0 inactive items", "String representation is wrong generated")
  end

  def test_sales
    old_owner = Models::User.created("Old", "password")
    new_owner = Models::User.created("New", "password")

    sock = old_owner.create_item("sock",10)
    assert( !sock.is_active?, "item should not be active, is")
    assert( !old_owner.list_items_inactive[0].is_active?, "item should not be active, is")

    old_owner.list_items_inactive[0].to_active
    assert( sock.is_active?, "item should be active, is not")
    assert( old_owner.list_items[0].is_active?, "item should be active, is not")

    if new_owner.buy_new_item?(sock)
      old_owner.remove_item(sock)
    end

    assert(old_owner.list_items.size==0)
    assert(old_owner.list_items_inactive.size==0)
    assert(new_owner.list_items.size==0)
    assert(new_owner.list_items_inactive.size==1)

    assert( !sock.is_active?, "item should not be active, is")
    assert( !new_owner.list_items_inactive[0].is_active?, "item should not be active, is")

    assert(old_owner.get_credits == 110, "Seller should now have more money")
    assert(new_owner.get_credits == 90, "Buyer should now have less money")
  end

  def test_sales_not_possible_because_of_price
    old_owner = Models::User.created("Old", "password")
    new_owner = Models::User.created("New", "password")

    sock = old_owner.create_item("sock",210)
    assert( !sock.is_active?, "item should not be active, is")

    sock.to_active
    assert( sock.is_active?, "item should be active, is not")

    if new_owner.buy_new_item?(sock)
      old_owner.remove_item(sock)
    end

    assert(old_owner.list_items_inactive.size==0)
    assert(old_owner.list_items.size==1)
    assert(new_owner.list_items_inactive.size==0)
    assert(new_owner.list_items.size==0)

    assert( sock.is_active?, "item should be active, is not")

    assert(old_owner.get_credits == 100, "Money should be like before")
    assert(new_owner.get_credits == 100, "Money should be like before")
  end

  def test_method_list_active
    owner = Models::User.created( "testuser", "password" )
    owner.create_item("testobject", 10)
    owner.create_item("testobject2", 50)
    owner.list_items_inactive[0].to_active
    owner.list_items_inactive[0].to_active
    assert(owner.list_items[0].to_s == "testobject, 10")
    assert(owner.list_items[1].to_s == "testobject2, 50")
  end

  def test_method_list_inactive
    owner = Models::User.created( "testuser", "password" )
    owner.create_item("testobject", 10)
    owner.create_item("testobject2", 50)
    assert(owner.list_items_inactive[0].to_s == "testobject, 10")
    assert(owner.list_items_inactive[1].to_s == "testobject2, 50")
    owner.list_items_inactive[0].to_active
    owner.list_items_inactive[0].to_active
    assert(owner.list_items[0].to_s == "testobject, 10")
    assert(owner.list_items[1].to_s == "testobject2, 50")
    owner.list_items[0].to_inactive
    owner.list_items[0].to_inactive
    assert(owner.list_items_inactive[0].to_s == "testobject, 10")
    assert(owner.list_items_inactive[1].to_s == "testobject2, 50")
  end
end
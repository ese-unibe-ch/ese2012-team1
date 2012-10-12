def relative(path)
  File.join(File.expand_path(File.dirname(__FILE__)), path)
end
require 'test/unit'
require 'rubygems'
require 'require_relative'
require_relative('../app/models/user')
require_relative('../app/models/item')
require_relative('../app/models/account')
require_relative('../app/models/system')

class UserTest < Test::Unit::TestCase


  def setup
    a = Models::System.instance
    a.users.clear
    Models::User.created("testuser", "password", "user@mail.ch", "Hey there", "../images/users/default_avatar.png")
  end

  #def teardown
    Models::System.instance.users.clear
 # end

  ##
  #
  # Save and clear
  #
  ##

  def test_should_remove_from_list_of_users
    detected_user = Models::User.get_all(nil).detect{|user| user == Models::System.instance.users}
    assert(detected_user != nil, "Should be in list")
    Models::System.instance.users.clear
    detected_user = Models::User.get_all(nil).detect{|user| user == Models::System.instance.users}
    assert(detected_user == nil, "Should be removed from list")
  end

  ##
  #
  # User creation
  #
  ##

  def test_should_create_user
    assert(Models::System.instance.users != nil, "Should create a test user")
  end

  def test_should_have_name
    assert(Models::System.instance.users.name == "testuser", "Should have name")
  end

  def test_should_have_password
    assert(Models::System.instance.users.password_hash != nil, "Should set password hash")
    assert(Models::System.instance.users.password_salt != nil, "Should set password salt")
  end

  def test_should_have_description
    assert(Models::System.instance.users.description = "Hey there")
  end

  def test_should_have_path_to_avatar
    assert(Models::System.instance.users.avatar = "C:/bild.gif")
  end

  def test_should_have_email
    assert(Models::System.instance.users.email == "user@mail.ch", "Should have email")
  end

  def test_should_have_unique_email_adresse
    assert_false(Models::User.created("testuser2", "password2", "user@mail.ch", "Hey there2", "C:/bild2.gif"), "Didn't throw a RuntimeError")
  end

  def test_should_accept_password
    assert(Models::User.login("user@mail.ch", "password"), "Should login")
  end

  def test_should_not_accept_password
    assert(! Models::User.login("user@mail.ch", "passwor"), "Should not login")
  end

  ##
  #
  # Item creation
  #
  ##

  def test_user_item_create
    assert( Models::System.instance.users.list_items.size == 0, "Item list length should be 0" )
    assert( Models::System.instance.users.list_items_inactive.size == 0, "Item list inactive length should be 0" )
    Models::System.instance.users.create_item("testobject", 10)
    assert( Models::System.instance.users.list_items.size == 0, "Item list length should be 0" )
    assert( Models::System.instance.users.list_items_inactive.size == 1, "Item list inactive length should be 1" )
    assert( !Models::System.instance.users.list_items_inactive[0].is_active?, "New created item should be inactive" )
    Models::System.instance.users.list_items_inactive[0].to_active
    assert( Models::System.instance.users.list_items.size == 1, "Item list length should be 1" )
    assert( Models::System.instance.users.list_items_inactive.size == 0, "Item list inactive length should be 0" )
    assert( Models::System.instance.users.list_items[0].is_active? , "New created item should now be active" )
    assert( Models::System.instance.users.list_items[0].to_s, "testobject, 10" )
  end

  def test_create_user
    assert( Models::System.instance.fetch_user("user@mail.ch").name == "testuser", "Name should be correct")
    assert( Models::System.instance.fetch_user("user@mail.ch").get_credits == 100, "Credits should be 100 first")
    assert( Models::System.instance.fetch_user("user@mail.ch").to_s == "testuser has currently 100 credits", "String representation is wrong generated")
  end

  def test_sales
    old_owner = Models::User.created("Old", "password", "old@mail.ch", "i'm old", "../images/users/default_avatar.png" )
    new_owner = Models::User.created("New", "password", "new@mail.ch", "i'm new", "../images/users/default_avatar.png")

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

    old_owner.clear
    new_owner.clear
  end

  def test_sales_not_possible_because_of_price
    old_owner = Models::User.created("Old", "password", "old@mail.ch", "i'm old", "../images/users/default_avatar.png")
    new_owner = Models::User.created("New", "password", "new@mail.ch", "i'm new", "../images/users/default_avatar.png")

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

    old_owner.clear
    new_owner.clear
  end

  def test_method_list_active
    user =  Models::System.instance.fetch_user("user@mail.ch")
    user.create_item("testobject", 10)
    user.create_item("testobject2", 50)
    list = user.list_items_inactive
    list do |e|
      e.to_active
    end
    assert(Models::System.instance.users.list_items[0].to_s == "testobject, 10")
    assert(Models::System.instance.users.list_items[1].to_s == "testobject2, 50")
  end

  def test_method_list_inactive
    Models::System.instance.users.create_item("testobject", 10)
    Models::System.instance.users.create_item("testobject2", 50)
    assert(Models::System.instance.users.list_items_inactive[0].to_s == "testobject, 10")
    assert(Models::System.instance.users.list_items_inactive[1].to_s == "testobject2, 50")
    Models::System.instance.users.list_items_inactive[0].to_active
    Models::System.instance.users.list_items_inactive[0].to_active
    assert(Models::System.instance.users.list_items[0].to_s == "testobject, 10")
    assert(Models::System.instance.users.list_items[1].to_s == "testobject2, 50")
    Models::System.instance.users.list_items[0].to_inactive
    Models::System.instance.users.list_items[0].to_inactive
    assert(Models::System.instance.users.list_items_inactive[0].to_s == "testobject, 10")
    assert(Models::System.instance.users.list_items_inactive[1].to_s == "testobject2, 50")
  end

  def test_user_should_have_item
    assert(!Models::System.instance.users.has_item?('testobject2'))
    Models::System.instance.users.create_item("testobject2", 50)
    assert(Models::System.instance.users.has_item?('testobject2'))
  end

  def test_user_should_return_item
    assert_raise(RuntimeError) { Models::System.instance.users.get_item('testobject2') }
    item_created = Models::System.instance.users.create_item("testobject2", 50)
    item_get = Models::System.instance.users.get_item('testobject2')
    assert(item_created == item_get, "Both items should be same but where #{item_get} and #{item_created}")
  end
end
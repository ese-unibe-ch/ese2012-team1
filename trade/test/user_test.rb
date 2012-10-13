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
    a.items.clear
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
    detected_user = Models::System.instance.fetch_user("user@mail.ch")
    assert(detected_user != nil, "Should be in list")
    Models::System.instance.users.clear
    assert_raise(RuntimeError){  Models::System.instance.fetch_user("user@mail.ch")}
  end

  ##
  #
  # User creation
  #
  ##

  def test_should_create_user
    assert(Models::System.instance.fetch_user("user@mail.ch") != nil, "Should create a test user")
  end

  def test_should_have_name
    assert(Models::System.instance.fetch_user("user@mail.ch").name == "testuser", "Should have name")
  end

  def test_should_have_password
    assert(Models::System.instance.fetch_user("user@mail.ch").password_hash != nil, "Should set password hash")
    assert(Models::System.instance.fetch_user("user@mail.ch").password_salt != nil, "Should set password salt")
  end

  def test_should_have_description
    assert(Models::System.instance.fetch_user("user@mail.ch").description = "Hey there")
  end

  def test_should_have_path_to_avatar
    assert(Models::System.instance.fetch_user("user@mail.ch").avatar = "C:/bild.gif")
  end

  def test_should_have_email
    assert(Models::System.instance.fetch_user("user@mail.ch").email == "user@mail.ch", "Should have email")
  end

  def test_should_have_unique_email_adresse
    assert_raise(RuntimeError){Models::User.created("testuser2", "password2", "user@mail.ch", "Hey there2", "C:/bild2.gif")}
  end

  def test_should_accept_password
    assert(Models::User.login("user@mail.ch", "password"), "Should login")
  end

  def test_should_not_accept_password
    assert(!Models::User.login("user@mail.ch", "passwor"), "Should not login")
  end

  ##
  #
  # Item creation
  #
  ##

  def test_user_item_create
    assert(Models::System.instance.fetch_items_of("user@mail.ch").size == 0, "Item list length should be 0")
    assert(Models::System.instance.fetch_user("user@mail.ch").list_items_inactive.size == 0, "Item list inactive length should be 0")
    Models::System.instance.fetch_user("user@mail.ch").create_item("testobject", 10)
    assert(Models::System.instance.fetch_user("user@mail.ch").list_items.size == 0, "Item list length should be 0")
    assert(Models::System.instance.fetch_user("user@mail.ch").list_items_inactive.size == 1, "Item list inactive length should be 1")
    assert(!Models::System.instance.fetch_user("user@mail.ch").list_items_inactive[0].is_active?, "New created item should be inactive")
    Models::System.instance.fetch_user("user@mail.ch").list_items_inactive[0].to_active
    assert(Models::System.instance.fetch_user("user@mail.ch").list_items.size == 1, "Item list length should be 1")
    assert(Models::System.instance.fetch_user("user@mail.ch").list_items_inactive.size == 0, "Item list inactive length should be 0")
    assert(Models::System.instance.fetch_user("user@mail.ch").list_items[0].is_active?, "New created item should now be active")
    assert(Models::System.instance.fetch_user("user@mail.ch").list_items[0].to_s, "testobject, 10")
  end

  #test for creation of an organisation by a user
  def test_user_organisation_create
    Models::System.instance.fetch_user("user@mail.com").create_organisation("org", "I'm an organisation.")
    assert(Models::System.instance.fetch_organisations_of("user@mail.ch").size == 1, "Amount of organisations should be 1.")
    assert_equal(Models::System.instance.fetch_organisation("org").name, "org")
    assert_equal(Models::System.instance.fetch_organisation("org").description, "I'm an organisation.")
    assert_equal(Models::System.instance.fetch_organisation("org").credits, 100)
    assert(Models::System.instance.fetch_organistaion("org").admin_list.size == 1, "Should have one admin.")
    assert(Models::System.instance.fetch_organisation("org").list_admins[0].name, "testuser")
    assert(Models::System.instance.fetch_organisation("org").users.size == 1, "Should have one user.")
    assert(Models::System.instance.fetch_organisation("org").list_users[0].name, "testuser")
  end

  def test_create_user
    assert(Models::System.instance.fetch_user("user@mail.ch").name == "testuser", "Name should be correct")
    assert(Models::System.instance.fetch_user("user@mail.ch").get_credits == 100, "Credits should be 100 first")
    assert(Models::System.instance.fetch_user("user@mail.ch").to_s == "testuser has currently 100 credits", "String representation is wrong generated")
  end

  def test_sales
    old_owner = Models::User.created("Old", "password", "old@mail.ch", "i'm old", "../images/users/default_avatar.png")
    new_owner = Models::User.created("New", "password", "new@mail.ch", "i'm new", "../images/users/default_avatar.png")

    sock = old_owner.create_item("sock", 10)
    assert(!sock.is_active?, "item should not be active, is")
    assert(!old_owner.list_items_inactive[0].is_active?, "item should not be active, is")

    old_owner.list_items_inactive[0].to_active
    assert(sock.is_active?, "item should be active, is not")
    assert(old_owner.list_items[0].is_active?, "item should be active, is not")

    if new_owner.buy_new_item?(sock)
      old_owner.remove_item(sock)
    end

    assert(old_owner.list_items.size==0)
    assert(old_owner.list_items_inactive.size==0)
    assert(new_owner.list_items.size==0)
    assert(new_owner.list_items_inactive.size==1)

    assert(!sock.is_active?, "item should not be active, is")
    assert(!new_owner.list_items_inactive[0].is_active?, "item should not be active, is")

    assert(old_owner.get_credits == 110, "Seller should now have more money")
    assert(new_owner.get_credits == 90, "Buyer should now have less money")

    old_owner.clear
    new_owner.clear
  end

  def test_sales_not_possible_because_of_price
    old_owner = Models::User.created("Old", "password", "old@mail.ch", "i'm old", "../images/users/default_avatar.png")
    new_owner = Models::User.created("New", "password", "new@mail.ch", "i'm new", "../images/users/default_avatar.png")

    sock = old_owner.create_item("sock", 210)
    assert(!sock.is_active?, "item should not be active, is")

    sock.to_active
    assert(sock.is_active?, "item should be active, is not")

    if new_owner.buy_new_item?(sock)
      old_owner.remove_item(sock)
    end

    assert(old_owner.list_items_inactive.size==0)
    assert(old_owner.list_items.size==1)
    assert(new_owner.list_items_inactive.size==0)
    assert(new_owner.list_items.size==0)

    assert(sock.is_active?, "item should be active, is not")

    assert(old_owner.get_credits == 100, "Money should be like before")
    assert(new_owner.get_credits == 100, "Money should be like before")

    old_owner.clear
    new_owner.clear
  end

  def test_method_list_active
    a = Models::System.instance
    a.users.clear
    a.items.clear
    Models::User.created("testuser", "password", "user@mail.ch", "Hey there", "../images/users/default_avatar.png")
    user = Models::System.instance.fetch_user("user@mail.ch")
    a = user.create_item("testobject", 10)
    b = user.create_item("testobject2", 50)
    user.list_items_inactive { |e| e.to_active }
    assert(Models::System.instance.fetch_user("user@mail.ch").list_items[0] == b, "Should be item \'testobject2\' but was #{Models::System.instance.fetch_user("user@mail.ch").list_items[0]}")
    assert(Models::System.instance.fetch_user("user@mail.ch").list_items[1] == a, "Should be item \'testobject\' but was #{Models::System.instance.fetch_user("user@mail.ch").list_items[1]}")
  end

  def test_method_list_inactive
    a = Models::System.instance
    a.users.clear
    a.items.clear
    Models::User.created("testuser", "password", "user@mail.ch", "Hey there", "../images/users/default_avatar.png")
    user = Models::System.instance.fetch_user("user@mail.ch")
    user.create_item("testobject", 10)
    user.create_item("testobject2", 50)
    assert(Models::System.instance.fetch_user("user@mail.ch").list_items_inactive[0].to_s.=="testobject, 10")
    assert(Models::System.instance.fetch_user("user@mail.ch").list_items_inactive[1].to_s =="testobject2, 50")
  end

  def test_user_should_have_item
    a = Models::System.instance
    a.users.clear
    a.items.clear
    Models::User.created("testuser", "password", "user@mail.ch", "Hey there", "../images/users/default_avatar.png")
    assert(Models::System.instance.fetch_user("user@mail.ch").has_item?('testobject2')==false)
    Models::System.instance.fetch_user("user@mail.ch").create_item("testobject2", 50)
    assert(Models::System.instance.fetch_user("user@mail.ch").has_item?(Models::System.instance.items.index('testobject2')))
  end

  def test_user_should_return_item
    a = Models::System.instance
    a.users.clear
    a.items.clear
    Models::User.created("testuser", "password", "user@mail.ch", "Hey there", "../images/users/default_avatar.png")
    assert_raise(RuntimeError) { Models::System.instance.fetch_user("user@mail.ch").get_item(Models::System.instance.items.index('testobject2')) }
    item_created = Models::System.instance.fetch_user("user@mail.ch").create_item("testobject2", 50)
    item_get = Models::System.instance.fetch_user("user@mail.ch").get_item(Models::System.instance.items.index('testobject2'))
    assert(item_created == item_get, "Both items should be same but where #{item_get} and #{item_created}")
  end
end
def relative(path)
  File.join(File.expand_path(File.dirname(__FILE__)), path)
end

require 'test/unit'
require 'rubygems'
require 'require_relative'
require_relative('../../app/models/user')
require_relative('../../app/models/item')
require_relative('../../app/models/account')
require_relative('../../app/models/system')

class UserTest < Test::Unit::TestCase


  def setup
    Models::System.instance.reset

    @user = Models::User.created("testuser", "password", "user@mail.ch", "Hey there", "../images/users/default_avatar.png")
  end

  def teardown
    Models::System.instance.reset
  end

  ##
  #
  # Save and clear
  #
  ##

  def test_should_remove_from_list_of_users
    detected_user = Models::System.instance.fetch_account(@user.id)
    assert(detected_user != nil, "Should be in list")
    Models::System.instance.reset
    assert_raise(RuntimeError){  Models::System.instance.fetch_account(@user.id) }
  end

  ##
  #
  # User creation
  #
  ##

  def test_should_create_user
    assert(Models::System.instance.fetch_account(@user.id) != nil, "Should create a test user in system")
  end

  def test_should_have_name
    assert(Models::System.instance.fetch_account(@user.id).name == "testuser", "Should have name")
  end

  def test_should_have_password
    assert(Models::System.instance.fetch_account(@user.id).password_hash != nil, "Should set password hash")
    assert(Models::System.instance.fetch_account(@user.id).password_salt != nil, "Should set password salt")
  end

  def test_should_have_description
    assert(Models::System.instance.fetch_account(@user.id).description = "Hey there")
  end

  def test_should_have_path_to_avatar
    assert(Models::System.instance.fetch_account(@user.id).avatar = "C:/bild.gif")
  end

  def test_should_have_email
    assert(Models::System.instance.fetch_account(@user.id).email == "user@mail.ch", "Should have email")
  end

  def test_should_have_unique_email_adresse
    assert_raise(RuntimeError){Models::User.created("testuser2", "password2", "user@mail.ch", "Hey there2", "C:/bild2.gif")}
  end

  def test_should_accept_password
    assert(Models::User.login(@user, "password"), "Should login")
  end

  def test_should_not_accept_password
    assert(!Models::User.login(@user, "passwor"), "Should not login")
  end

  ##
  #
  # Item creation
  #
  ##

  def test_user_item_create
    assert(Models::System.instance.fetch_items_of(@user.id).size == 0, "Item list length should be 0")
    assert(Models::System.instance.fetch_account(@user.id).list_items_inactive.size == 0, "Item list inactive length should be 0")
    Models::System.instance.fetch_account(@user.id).create_item("testobject", 10)
    assert(Models::System.instance.fetch_account(@user.id).list_items.size == 0, "Item list length should be 0")
    assert(Models::System.instance.fetch_account(@user.id).list_items_inactive.size == 1, "Item list inactive length should be 1")
    assert(!Models::System.instance.fetch_account(@user.id).list_items_inactive[0].is_active?, "New created item should be inactive")
    Models::System.instance.fetch_account(@user.id).list_items_inactive[0].to_active
    assert(Models::System.instance.fetch_account(@user.id).list_items.size == 1, "Item list length should be 1")
    assert(Models::System.instance.fetch_account(@user.id).list_items_inactive.size == 0, "Item list inactive length should be 0")
    assert(Models::System.instance.fetch_account(@user.id).list_items[0].is_active?, "New created item should now be active")
    assert(Models::System.instance.fetch_account(@user.id).list_items[0].to_s, "testobject, 10")
  end

  #test for creation of an organisation by a user
  def test_user_organisation_create
    user = Models::System.instance.fetch_account(@user.id)
    org = user.create_organisation("org", "I'm an organisation.", "../images/users/default_avatar.png")
    org.add_member(user)

    assert_equal(org.name, "org")
    assert_equal(org.description, "I'm an organisation.")
    assert_equal(org.credits, 100)
    assert(Models::System.instance.accounts.size == 2, "Should have one account (user and organisation.")
    assert(org.is_member?(user))
  end

  def test_create_user
    assert(Models::System.instance.fetch_account(0).name == "testuser", "Name should be correct")
    assert(Models::System.instance.fetch_account(0).credits == 100, "Credits should be 100 first")
    assert(Models::System.instance.fetch_account(0).to_s == "testuser has currently 100 credits", "String representation is wrong generated")
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

    if sock.can_be_bought_by?(new_owner)
      new_owner.buy_item(sock)
    end

    assert(old_owner.list_items.size==0)
    assert(old_owner.list_items_inactive.size==0)
    assert(new_owner.list_items.size==0)
    assert(new_owner.list_items_inactive.size==1)

    assert(!sock.is_active?, "item should not be active, is")
    assert(!new_owner.list_items_inactive[0].is_active?, "item should not be active, is")

    assert(old_owner.credits == 110, "Seller should now have more money")
    assert(new_owner.credits == 90, "Buyer should now have less money")
  end

  def test_sales_not_possible_because_of_price
    old_owner = Models::User.created("Old", "password", "old@mail.ch", "i'm old", "../images/users/default_avatar.png")
    new_owner = Models::User.created("New", "password", "new@mail.ch", "i'm new", "../images/users/default_avatar.png")

    sock = old_owner.create_item("sock", 210)
    assert(!sock.is_active?, "item should not be active, is")

    sock.to_active
    assert(sock.is_active?, "item should be active, is not")

    if sock.can_be_bought_by?(new_owner)
      old_owner.remove_item(sock)
    end

    assert(old_owner.list_items_inactive.size==0)
    assert(old_owner.list_items.size==1)
    assert(new_owner.list_items_inactive.size==0)
    assert(new_owner.list_items.size==0)

    assert(sock.is_active?, "item should be active, is not")

    assert(old_owner.credits == 100, "Money should be like before")
    assert(new_owner.credits == 100, "Money should be like before")
  end

  def test_fetch_items_of_a_user
    user = Models::User.created("testuser", "password", "user@mail.ch", "Hey there", "../images/users/default_avatar.png")
    a = user.create_item("testobject", 10)
    b = user.create_item("testobject2", 50)

    user.list_items_inactive { |e| e.to_active }

    item0 = Models::System.instance.fetch_items_of(user.id)[0]
    item1 = Models::System.instance.fetch_items_of(user.id)[1]
    assert(item0 == a, "Should be item \'testobject2\' but was #{item0}")
    assert(item1 == b, "Should be item \'testobject\' but was #{item1}")
  end

  def test_method_list_inactive
    #have to be implemented
  end

  def test_user_should_have_item
    assert(! Models::System.instance.fetch_account(@user.id).has_item?('testobject2'))
    item = Models::System.instance.fetch_account(@user.id).create_item("testobject2", 50)
    assert(Models::System.instance.fetch_account(@user.id).has_item?(item.id))
  end

  def test_user_should_return_item
    assert_raise(RuntimeError) { Models::System.instance.fetch_account(@user.id).get_item(2) }

    item_created = @user.create_item("testobject2", 50)
    item_get = @user.get_item(item_created.id)
    assert(item_created == item_get, "Both items should be same but where #{item_get} and #{item_created}")
  end
end
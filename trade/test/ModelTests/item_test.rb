require 'test/unit'
require 'rubygems'
require 'ftools'

require 'require_relative'
require_relative('../../app/models/user')
require_relative('../../app/models/item')
require_relative('../../app/models/system')

class ItemTest < Test::Unit::TestCase

  @owner

  def setup
    Models::System.instance.reset
    @owner = Models::User.created("testuser", "password", "user@mail.ch", "Hey there", "/images/users/default_avatar.png")
  end

  def teardown
    Models::System.instance.reset
  end

  #test if item is initialized correctly
  def test_item_initialisation
    item = Models::Item.created("testobject", 50, @owner)
    assert(item.name == "testobject", "Name should be returned")
    assert(item.price == 50, "Should return price")
    assert(!item.is_active?, "Should not be active")
    assert(item.id == nil, "Id should be nil after initialization (is to be set by system) but was #{item.id}")
  end

  #test for item activation
  def test_item_activation
    item = Models::Item.created("testobject", 50, @owner)
    assert(item.name == "testobject", "Name should be returned")
    assert(item.price == 50, "Should return price")
    assert(!item.is_active?, "Should not be active")
    item.to_active
    assert(item.name == "testobject", "Name should be returned")
    assert(item.price == 50, "Should return price")
    assert(item.is_active?, "Should be active now")
  end

  #test for item deactivation
  def test_item_deactivation
    item = Models::Item.created("testobject", 50, @owner)
    assert(item.price == 50, "Should return price")
    assert(!item.is_active?, "Should not be active")
    item.to_active
    assert(item.price == 50, "Should return price")
    assert(item.is_active?, "Should be active now")
    item.to_inactive
    assert(item.price == 50, "Should return price")
    assert(! item.is_active?, "Should be inactive now")
  end

  #test if adding of description generally works
  def test_description_adding
    item = Models::Item.created("Test object", 20, @owner)
    assert_equal(item.owner, @owner)
    item.add_description("I'm an object for testing.")
    assert_equal(item.description, "I'm an object for testing.")
  end

  #test if adding of picture generally works
  def test_picture_adding
    item = Models::Item.created("Test object", 20, @owner)
    item.add_picture("/images/items/default_item.png")
    assert_equal(item.picture, "/images/items/default_item.png")
  end

  #test if the checking of editability works correctly
  def test_editability
    item = Models::Item.created("book", 50, @owner)
    assert_equal(item.is_active?, false)
    item.to_active
    assert(item.editable?, true)
  end

  def test_should_be_buyable
    item = Models::Item.created("book", 50, @owner)
    item.to_active

    buyer = Models::User.created("testuser2", "password", "user2@mail.ch", "Hey there", "/images/users/default_avatar.png")

    assert(item.can_be_bought_by?(buyer))
  end

  def test_should_not_be_buyable_if_deactive
    item = Models::Item.created("book", 50, @owner)

    buyer = Models::User.created("testuser2", "password", "user2@mail.ch", "Hey there", "/images/users/default_avatar.png")

    assert(! item.can_be_bought_by?(buyer))
  end

  def test_should_not_be_buyable_if_price_to_high
    item = Models::Item.created("book", 150, @owner)
    item.to_active

    buyer = Models::User.created("testuser2", "password", "user2@mail.ch", "Hey there", "/images/users/default_avatar.png")

    assert(! item.can_be_bought_by?(buyer))
  end

  def test_should_remove_item_from_system
    item = @owner.create_item("book", 150)
    File.copy("../../app/public/images/users/default_avatar.png", "../../app/public/images/items/test.png")
    item.add_picture("/images/items/test.png")

    item.clear

    assert(! File.exists?("../../app/public/images/items/test.png"))
  end
end
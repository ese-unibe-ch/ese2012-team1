require 'test/unit'
require 'rubygems'
require 'require_relative'

require_relative('../../app/models/account')

class Models::Account
  @saved = false

  def save
    @saved = true
  end

  def saved?
    @saved
  end
end

class AccountTest < Test::Unit::TestCase

  def setup
    Models::System.instance.reset
  end

  def teardown
    Models::System.instance.reset
  end

  def test_initialization
    create_account
  end

  def create_account
    account = Models::Account.created("Pascal", "Pascals account", "../images/users/default_avatar.png")

    assert(account.name == "Pascal", "Should have name")
    assert(account.description == "Pascals account", "Should have description")
    assert(account.avatar == "../images/users/default_avatar.png", "Should have avatar")
    assert(account.credits == 100, "Should have 100 credits")
    assert(account.saved?, "Should be saved to system")

    account
  end

  def test_should_create_item_and_add_it_to_system
    account = create_account
    item = account.create_item("Chaos", 100)

    assert(Models::System.instance.items.size == 1)
    assert(Models::System.instance.items.member?(item.id))
  end

  # test for item's owner after selling
  def test_should_buy_item
    account1 = create_account
    item = account1.create_item("Chaos", 100)
    assert(item.owner == account1, "Pascal should be owner of \'Chaos\'")

    account2 = Models::Account.created("Judith", "Judiths account", "../images/users/default_avatar.png")
    account2.buy_item(item)
    assert(item.owner == account2, "Judith should be owner of \'Chaos\'")
    assert(account1.credits == 200, "Pascal should earn 100 credits")
    assert(account2.credits == 0, "Judith should pay 100 credits")
  end
end
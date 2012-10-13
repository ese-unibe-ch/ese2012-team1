require 'test/unit'
require 'rubygems'
require 'require_relative'

require_relative('../app/models/account')

class AccountTest < Test::Unit::TestCase

  def teardown
    Models::System.instance.items = Hash.new
    Models::System.instance.users = Hash.new
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

    account
  end

  def test_should_create_item_and_add_it_to_system
    account = create_account
    account.create_item("Chaos", 100)

    assert(Models::System.instance.items.size == 1) #Not a really good test...
  end

  # test for item's owner after selling
  def test_should_buy_item
    account1 = create_account
    item = account1.create_item("Chaos", 100)
    assert(item.owner == account1, "Pascal should be owner of \'Chaos\'")

    account2 = Models::Account.created("Judith", "Judiths account", "../images/users/default_avatar.png")
    account2.buy_item(item)
    assert(item.owner == account2, "Judith should be owner of \'Chaos\'")
  end
end
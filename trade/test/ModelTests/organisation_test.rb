require "test/unit"
require "../../app/models/organisation"

class MockUser
  attr_accessor :email, :id

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

class OrganisationTest < Test::Unit::TestCase
  def setup
    Models::System.instance.reset
  end

  def teardown
    Models::System.instance.reset
  end

  def init
    organisation = Models::Organisation.created("Pascal", "Pascals account", "../images/users/default_avatar.png")

    assert(organisation.name == "Pascal", "Should have name")
    assert(organisation.description == "Pascals account", "Should have description")
    assert(organisation.avatar == "../images/users/default_avatar.png", "Should have avatar")

    assert(Models::System.instance.accounts.size == 1, "There should be one organisation")
    assert(Models::System.instance.accounts.one? {|id, org| org == organisation})

    organisation
  end

  def test_initialization
    init
  end

  def test_added_user_should_be_in_user_list
    org = init
    user = MockUser.new
    org.add_member(user)

    assert(org.users.member?(user.email), "Should be in user list")
  end

  def test_an_added_user_should_be_member
    org = init
    user = MockUser.new
    org.add_member(user)

    assert(org.is_member?(user), "Should be a member!")
  end
end
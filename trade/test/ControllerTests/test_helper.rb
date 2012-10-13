##
#
# This class holds some helper method for testing
#
##

class TestHelper

  @@users = Hash.new
  @@items = Hash.new

  ##
  #
  # Clears all users and loads test data afterwards.
  #
  ##

  def self.load
    self.clear_all
    @@items = Hash.new
    @@users = Hash.new

    bart = Models::User.created('Bart' , 'bart', 'bart@mail.ch', 'I\' should not...', '../images/users/default_avatar.png')
    @@users.store(:bart, bart)
    @@items.store(:skateboard, bart.create_item('Skateboard', 100))
    @@items.store(:elephant, bart.create_item('Elephant', 50))
    @@items[:skateboard].to_active

    homer = Models::User.created('Homer', 'homer', 'homer@mail.ch', 'Do!', '../images/users/default_avatar.png')
    @@users.store(homer.name, homer)
    @@items.store(:beer, homer.create_item('Beer', 200))
    @@items[:beer].to_active
  end

  ##
  #
  # Returns all users created in this test helper as hash:
  # username => user
  #
  ##

  def self.get_users
    @@users
  end

  ##
  #
  # Returns all items created in this test helper as hash
  # itemname => item
  #
  ##

  def self.get_items
    @@items
  end

  ##
  #
  # Clears all users from user list in Module::User
  #
  ##

  def self.clear_all
    Models::System.instance.users = Hash.new
    Models::System.instance.items = Hash.new
  end
end
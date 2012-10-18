require 'ftools'

##
#
# This class holds some helper method for testing
#
##

class TestHelper

  @@users = Hash.new
  @@items = Hash.new
  @@sessions = Hash.new

  ##
  #
  # Clears all users and loads test data afterwards.
  #
  ##

  def self.load
    self.clear_all
    self.reset

    # Create pictures for item picture
    File.copy("../../app/public/images/users/default_avatar.png", "../../app/public/images/items/test_elephant.png")
    File.copy("../../app/public/images/users/default_avatar.png", "../../app/public/images/items/test_skateboard.png")
    File.copy("../../app/public/images/users/default_avatar.png", "../../app/public/images/items/test_beer.png")

    # Create bart
    bart = Models::User.created('Bart' , 'bart', 'bart@mail.ch', 'I\' should not...', '/images/users/default_avatar.png')
    @@users.store(:bart, bart)

    ## Create items for bart
    item = bart.create_item('Skateboard', 50)
    item.add_picture("/images/items/test_skateboard.png")
    item.to_active
    @@items.store(:skateboard, item)

    item = bart.create_item('Elephant', 50)
    item.add_picture("/images/items/test_elephant.png")
    @@items.store(:elephant, item)


    ## Store session for bart
    @@sessions.store(:bart, { :auth => true, :user => bart.id, :account => bart.id })

    # Create Homer
    homer = Models::User.created('Homer', 'homer', 'homer@mail.ch', 'Do!', '/images/users/default_avatar.png')
    @@users.store(:homer, homer)

    ## Create items for homer
    item = homer.create_item('Beer', 200)
    item.add_picture("/images/items/test_beer.png")
    item.to_active
    @@items.store(:beer, item)

    ## Store session for homer
    @@sessions.store(:homer, { :auth => true, :user => homer.id, :account => homer.id })
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
  # Returns sessions for each user created in this test helper as hash
  # username => session
  #
  ##

  def self.get_sessions
    @@sessions
  end

  ##
  #
  # Clears all users from user list in Module::User
  #
  ##

  def self.clear_all
    Models::System.instance.reset
  end

  ##
  #
  # Resets all class variables
  #
  ##

  def self.reset
    @@items = Hash.new
    @@users = Hash.new
    @@sessions = Hash.new
  end

  class << self
    alias :reload :load
  end
end
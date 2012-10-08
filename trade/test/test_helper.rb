##
#
# This class holds some helper method for testing
#
##

class TestHelper

  ##
  #
  # Clears all users and loads test data afterwards.
  #
  ##

  def self.load
    self.clear_all

    bart = Models::User.created('Bart' , 'bart', 'bart@mail.ch', 'I\' should not...', '../images/users/default_avatar.png')
    bart.create_item('Skateboard', 100)
    bart.list_items_inactive.detect {|item| item.name == 'Skateboard' }.to_active

    homer = Models::User.created('Homer', 'homer', 'homer@mail.ch', 'Do!', '../images/users/default_avatar.png')
    homer.create_item('Beer', 200)
    homer.list_items_inactive.detect {|item| item.name == 'Beer' }.to_active
  end

  ##
  #
  # Clears all users from user list in Module::User
  #
  ##

  def self.clear_all
    Models::User.get_all(nil).each do |user|
      user.clear
    end
  end
end
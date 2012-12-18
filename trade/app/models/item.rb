module Models
  ##
  #
  # An item is a CommentContainer. So users can comment on it.
  # It also knows several information on itself, like the
  # name, price, and it's id.
  #
  # An item can be observed and notifies observers if it is
  # deactivated.
  #
  # +timed_event+:: Used to set an expiration date, after which the item becomes inactive
  # +name+::  the name of the item
  # +price+:: how much credits this item costs a buyer
  # +active+:: True then it can be sol and is not editable. If false then it can't be sold and is editable
  # +owner+:: who owns this item
  # +id+:: The id of this item (initially nil and is set by system)
  # +description_list+:: A list that contains all past describtion of this item (see ReversableDescription)
  # +description_position+:: Which of these descriptions is used now
  # +picture+:: path to the items picture
  # +version+:: how many times this item has been changed (starts with 1)
  # +observers+:: who should get a message if the item is changed
  #
  ##
  class Item < CommentContainer

    attr_accessor :description_list, :description_position, :name, :price, :owner, :id, :picture, :observers

    attr_reader :active, :version

    @timed_event

    def initialize
      super

      @active = false

      @description_list = ReversableDescription.new
      @description_position = 0

      @timed_event = TimedEvent.create(self, :forever)

      @version = 1
    end

    ##
    #
    # Factory method (constructor) of the class
    #
    # === Parameters
    #
    # +name+:: the name of the item (can't be nil)
    # +price+:: how much credits this item costs (can't be nil, must be greater than 0)
    # +owner+:: the user who owns this item (not nil)
    #
    ##
    def self.created(name, price, owner)
      #Preconditions
      fail "Item needs a name." if (name == nil)
      fail "Item needs a price." if (price == nil)
      fail "Item needs an owner." if (owner == nil)
      fail "Price can't be negative" if (price < 0)

      item = self.new
      item.id = nil
      item.name = name
      item.price = price
      item.owner = owner
      item.picture = "/images/items/default_item.png"
	    item.observers = []
      item
    end

    ##
    #
    # Returns true if item is active. False
    # otherwise.
    #
    # If an item is active it is on sold.
    # If it is inactive it can be edited.
    #
    ##
    def is_active?
      self.active
    end

    ##
    #
    # Returns string representation of an Item
    #
    ##
    def to_s
      "#{self.name}, #{self.price}"
    end

    ##
    #
    # Sets an expiration_date for item
    #
    # If this expiration date is over #timed_out
    # is called (see TimedEvent)
    #
    # +time+:: time when the item should expires (must be in future)
    #
    ##
    def add_expiration_date(time)
      fail "Time should not be in past" if time < Time.now
      @timed_event.reschedule(time)
    end

    ##
    #
    # Returns the expiration time of this
    # item. This is when #timed_event
    # is called.
    #
    # May return Time if the item can
    # expire or :forever if not.
    # (see TimedEvent)
    ##

    def get_expiration_date
      @timed_event.time
    end

    ##
    #
    # Sets the Item to inactive.
    #
    # Called when TimedEvent times out.
    #
    ##
    def timed_out
      self.to_inactive
    end

    ##
    #
    # Sets Item active and registers item
    # to the Search so it can be found
    # (see Search) again.
    #
    ##
    def to_active
      @active = true
      System.instance.search.register(SearchItemItem.create(self, "item", [:name, :description]))
    end

    ##
    #
    # Sets Item inactive
    #
    # Unschedules the TimedEvent and
    # unregisters it from Search.
    #
    # Notifies all observers that it
    # was deactivated.
    #
    ##
    def to_inactive
      @active = false
      @timed_event.unschedule
      System.instance.search.unregister(self)
      self.notify_observers
    end

    ##
    #
    # Notifies all observers that there was
    # an update. At the moment this method
    # is only called when an item is
    # deactivated.
    #
    #
    ##
    def notify_observers
      self.observers.each {|observer| observer.update(self)}
    end

    ##
    #
    # Adds an observer to the observers of this item.
    # At the moment this method is used by WishList.
    #
    # === Parameters
    #
    # +observers+:: The observer to be notified (can't be nil, must implement a update(item) method)
    #
    ##
    def add_observer(observer)
      fail "missing observer" if observer.nil?
      fail "must implement #update" unless (observer.respond_to(:update))

      self.observers << observer
    end

    ##
    #
    # Removes an observer from the observers of this item.
    # At the moment this method is used by WishList
    #
    # === Parameters
    #
    # +observer+:: The observer to be removed (can't be nil and must be an observer of this item)
    #
    ##
    def remove_observer(observer)
      fail "missing observer" if observer.nil?
      fail "#{observer} is not an observer of this item" unless self.observers.member?(observer)

      self.observers.delete(observer)
    end

    ##
    #
    # Adds a description to the item and updates the description list
    # accordingly. If a new description is added then this description
    # is displayed
    #
    # === Parameters
    #
    # +description+:: string containing the description for the item (can't be nil)
    #
    ##
    def add_description (description)
      # Precondition
      fail "Missing description." if (description == nil)

      self.description_list.add(description)
      self.description_position = self.description_list.version
    end

    ##
    #
    # Returns the current description. Shows always the selected
    # description in description_position. Returns an empty
    # String if there was no description set (see #add_description).
    #
    ##
    def description
      return "" if description_position == 0
      return self.description_list.show_version(description_position)
    end

    ##
    #
    # Adds a path to a picture to the item.
    #
    # The file that is added must exist in
    # the public folder. The given path must
    # be as it will be used in the view
    # For example if you have an image in
    # public/images/users called user.png
    # the path must be /images/users/user.png.
    #
    # === Parameters
    #
    # +picture+:: path to picture file for the item
    #             (can't be nil and file on this path must already exist)
    #
    ##
    def add_picture (picture)
      fail "Missing picture path." if (picture == nil)
      path = absolute_path(picture.sub("/images", "../public/images"), __FILE__)
      fail "There exists no file on path #{path}" unless (File.exists?(path))

      self.picture = picture
    end

    ##
    #
    # Checks if an item's attributes can be changed depending on its state.
    #
    # Returns true if state of the item is inactive, false otherwise.
    #
    ##
    def editable?
      ! self.is_active?
    end

    ##
    #
    # Removes itself from the list of items and of the system
    # and removes his picture. Unregisters from the Search.
    #
    ##
    def clear
      DAOItem.instance.remove_item(self.id)
      System.instance.search.unregister(self)

      unless self.picture =~ /default_item\.png$/
        File.delete(Helpers::absolute_path(self.picture.sub("/images", "../public/images"), __FILE__))
      end
    end

    ##
    #
    # Check if this item can be bought by an user
    #
    # Returns true if a specific user has enough credits to buy this item,
    # if the item is for sale and if the current owner is not the buyer
    #
    # === Parameters
    #
    # +user+:: Account who wants to check if he can buy this item (can't be nil)
    #
    ##
    def can_be_bought_by?(user)
      # Precondition
      fail "Missing user" if (user == nil)
      user.credits >= self.price && self.active && self.owner != user
    end

    ##
    #
    # Sets new owner and sets item to inactive.
    #
    # === Parameters
    #
    # +new_owner+:: Account that bought item (can't be nil)
    ##
    def bought_by(new_owner)
      # Precondition
      fail "Missing new owner" if (new_owner == nil)
      self.owner = new_owner
      self.to_inactive
    end

    ##
    #
    # Checks if the current version equals to the given
    # version
    #
    # Returns true if the last seen version is the same
    # as the current version of the item.
    #
    # This method can be used to check if somebody has
    # altered the item since last time the item was used.
    #
    # +seen_version+:: version the user has seen last
    #
    ##
    def current_version?(seen_version)
      # Precondition
      fail "Missing Version number" if (seen_version == nil)
      self.version == seen_version.to_i
    end

    ##
    #
    # Increases the version counter by one.
    # The version is used to check if an item
    # has changed since the last interaction with
    # it.
    #
    ##
    def alter_version
      @version += 1
    end
  end
end
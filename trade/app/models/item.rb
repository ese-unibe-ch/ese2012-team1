module Models
  class Item < CommentContainer
    ##
    #
    # An item is a CommentContainer. So users can comment on it.
    # It also has to know several information on itself, like the
    # name, price, and it's id.
    #
    # timed_event : Used to set an expiration date, after which the item becomes inactive
    # name :  the name of the item
    # price : how much credits this item costs a buyer
    # active: True=can be sold,uneditable  false=can't be sold, editable
    # owner : who owns this item
    # id : The id of this item (is set by system)
    # description_list : A list that contains all past descr. of this item
    # description_position : Which of these descriptions is used now
    # picture : how the item looks like
    # version : how many times this item has been changed (starts with 1)
    # observers : who should get a message if the item is changed
    #
    ##
    attr_accessor :timed_event, :name, :price, :active, :owner, :id, :description_list, :description_position, :picture, :version, :observers

    def initialize
      super
    end

    ##
    #
    # Factory method (constructor) of the class
    #
    # Expects:
    # name : the name of the item (not nil)
    # price : how much credits this item costs (not nil, not <0)
    # owner : the user who owns this item (not nil)
    #
    ##
    def self.created( name, price, owner)
      #Preconditions
      fail "Item needs a name." if (name == nil)
      fail "Item needs a price." if (price == nil)
      fail "Item needs an owner." if (owner == nil)
      fail "Price can't be negative" if (price < 0)

      item = self.new
      item.id = nil
      item.timed_event = TimedEvent.create(item, :forever)
      item.name = name
      item.price = price
      item.active = false
      item.owner = owner
      item.description_list = ReversableDescription.new
      item.description_position = 0
      item.picture = "/images/items/default_item.png"
      item.version = 1;
	    item.observers = []
      item
    end

    ##
    #
    # get state
    #
    ##
    def is_active?
      self.active
    end

    ##
    #
    # to String-method
    #
    ##
    def to_s
      "#{self.name}, #{self.price}"
    end

    ##
    #
    # Sets an expiration_date for item
    #
    ##
    def add_expiration_date(time)
      fail "Time should not be in past" if time < Time.now
      self.timed_event.reschedule(time)
    end

    ##
    #
    #called when timed event times out
    #
    ##
    def timed_out
      self.to_inactive
    end

    ##
    #
    # to set active
    #
    ##
    def to_active
      self.active = true
      System.instance.search.register(SearchItemItem.create(self, "item", [:name, :description]))
    end

    ##
    #
    # to set inactive
    #
    ##
    def to_inactive
      self.active = false
      self.timed_event.unschedule
      System.instance.search.unregister(self)
      self.notify_observers
    end



    #TODO test
    ##
    #
    # Notifies all observers when this item is
    # no longer available.
    #
    ##
    def notify_observers
      self.observers.each {|observer| observer.update(self)}
    end

    #TODO test
    ##
    #
    # adds a wishlist to the observers of this item.
    #
    # Expects:
    # wish_list : has to be initialised
    #
    ##
    def add_observer(wish_list)
      self.observers << wish_list
    end


    #TODO test
    ##
    #
    # removes a wishlist from the observers of this item.
    #
    # Ecxpects:
    # wish_list : has to be initialised and in
    #             the observers of this item
    #
    ##
    def remove_observer(wish_list)
      self.observers.delete(wish_list)
    end

    ##
    #
    # Adds a description to the item and updates the description list
    # accordingly
    #
    # Expects:
    # description : the string containing the description for the item
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
    # Returns the current description
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
    # Expects:
    # picture : path to picture file for the item(can't be nil)
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
    # @@return    true if state of the item is inactive;
    #             false otherwise.
    def editable?
      ! self.is_active?
    end

    ##
    #
    # Removes itself from the list of items and of the system
    # and removes his picture
    #
    ##
    def clear
      System.instance.remove_item(self.id)
      System.instance.search.unregister(self)

      unless self.picture =~ /default_item\.png$/
        File.delete(Helpers::absolute_path(self.picture.sub("/images", "../public/images"), __FILE__))
      end
    end

    ##
    #
    # Returns true if a specific user has enough credits to buy this item
    # and if the item is for sale
    #
    # Expects:
    # user : the user who wants to check if he can buy this item (can't be nil)
    #
    ##
    def can_be_bought_by?(user)
      # Precondition
      fail "Missing user" if (user == nil)
      user.credits >= self.price && self.active
    end

    ##
    #
    # Set new owner and set item to inactive.
    #
    ##
    def bought_by(new_owner)
      # Precondition
      fail "Missing new owner" if (new_owner == nil)
      self.owner = new_owner
      self.to_inactive
    end

    ##
    #
    # Returns if the last seen version is still up to date
    #
    ##
    def current_version?(seen_version)
      # Precondition
      fail "Missing Version number" if (seen_version == nil)
      self.version == seen_version.to_i
    end

    ##
    #
    # Increases the version counter by one
    #
    ##
    def alter_version()
      self.version += 1
    end
  end
end
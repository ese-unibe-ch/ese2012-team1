module Models
  class Item < CommentContainer
    #Items have a name.
    #Items have a price.
    #An item can be active or inactive.
    #An item has an owner.
    #An item can have a description.
    #An item can have a picture.

    # generate getter and setter for name and price
    attr_accessor :timed_event, :name, :price, :active, :owner, :id, :description_list, :description_position, :picture, :version

    def initialize
      super
      System.instance.search.register(SearchItemItem.create(self, "item", [:name, :description]))
    end

    # factory method (constructor) on the class
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
      item
    end

    # get state
    def is_active?
      self.active
    end

    # to String-method
    def to_s
      "#{self.name}, #{self.price}"
    end

    # Sets an expiration_date for item
    def add_expiration_date(time)
      fail "Time should not be in past" if time < Time.now
      self.timed_event.reschedule(time)
    end

    #called when timed event times out
    def timed_out
      self.to_inactive
    end

    # to set active
    def to_active
      self.active = true
    end

    # to set inactive
    def to_inactive
      self.active = false
      self.timed_event.unschedule
    end

    # Adds a description to the item.
    # @param  description   the string containing the description for the item
    def add_description (description)
      # Precondition
      fail "Missing description." if (description == nil)
      self.description_list.add(description)
      self.description_position = self.description_list.version
    end

    # Returns the current description
    #
    def description
      return "" if description_position == 0
      return self.description_list.show_version(description_position)
    end

    # Adds a path to a picture to the item.
    # @param  picture : path to picture file for the item
    def add_picture (picture)
      fail "Missing picture path." if (picture == nil)
      path = absolute_path(picture.sub("/images", "../public/images"), __FILE__)
      fail "There exists no file on path #{path}" unless (File.exists?(path))

      self.picture = picture
    end

    # Checks if an item's attributes can be changed depending on its state.
    # @@return    true if state of the item is inactive;
    #             false otherwise.
    def editable?
      ! self.is_active?
    end

    # Removes itself from the list of items and of the system
    # and removes his picture

    def clear
      System.instance.remove_item(self.id)
      System.instance.search.unregister(self)

      unless self.picture =~ /default_item\.png$/
        File.delete(Helpers::absolute_path(self.picture.sub("/images", "../public/images"), __FILE__))
      end
    end

    def can_be_bought_by?(user)
      # Precondition
      fail "Missing user" if (user == nil)
      user.credits >= self.price && self.active
    end

    #Set new owner and set item to inactive

    def bought_by(new_owner)
      # Precondition
      fail "Missing new owner" if (new_owner == nil)
      self.owner = new_owner
      self.to_inactive
    end

    def current_version?(seen_version)
      # Precondition
      fail "Missing Version number" if (seen_version == nil)
      self.version == seen_version.to_i
    end

    def alter_version()
      self.version += 1
    end
  end

end
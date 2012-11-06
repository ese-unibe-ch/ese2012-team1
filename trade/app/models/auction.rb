require 'rubygems'
require 'require_relative'

require_relative '../helpers/render'
require_relative 'system'
require_relative 'comment_container'

include Helpers

module Models
  class Auction
    #Items have a name.
    #Items have a price.
    #An item can be active or inactive.
    #An item has an owner.
    #An item can have a description.
    #An item can have a picture.

    # generate getter and setter for name and price
    attr_accessor :id, :item, :price, :increment, :start_time, :end_time, :money_storage_hash,
    # factory method (constructor) on the class
    def self.created( name, price, owner)
      #Preconditions
      fail "Item needs a name." if (name == nil)
      fail "Item needs a price." if (price == nil)
      fail "Item needs an owner." if (owner == nil)
      fail "Price can't be negative" if (price < 0)

      item = self.new
      item.id = nil
      item.name = name
      item.price = price
      item.active = false
      item.owner = owner
      item.description = ""
      item.picture = "/images/items/default_item.png"
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

    # to set active
    def to_active
      self.active = true
    end

    # to set inactive
    def to_inactive
      self.active = false
    end

    # Adds a description to the item.
    # @param  description   the string containing the description for the item
    def add_description (description)
      fail "Missing description." if (description == nil)
      self.description = description
    end

    # Adds a path to a picture to the item.
    # @param  picture : path to picture file for the item
    def add_picture (picture)
      fail "Missing picture." if (picture == nil)
      path = absolute_path(picture.sub("/images", "../public/images"), __FILE__)
      fail "There exists no file on path #{path}" unless (File.exists?(path))

      self.picture = picture
    end

    # Checks if an item's attributes can be changed depending on its state.
    # @@return    true if state of the item is active;
    #             false otherwise.
    def editable?
      self.is_active?
    end

    # Removes itself from the list of items and of the system
    # and removes his picture

    def clear
      System.instance.remove_item(self.id)

      unless self.picture =~ /default_item\.png$/
        File.delete(Helpers::absolute_path(self.picture.sub("/images", "../public/images"), __FILE__))
      end
    end

    def can_be_bought_by?(user)
      user.credits >= self.price && self.active
    end

    #Set new owner and set item to inactive

    def bought_by(new_owner)
      self.owner = new_owner
      self.to_inactive
    end
  end

end
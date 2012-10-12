require 'rubygems'
require 'require_relative'
require_relative '../helpers/render'

module Models

  class Item
    #Items have a name.
    #Items have a price.
    #An item can be active or inactive.
    #An item has an owner.
    #An item can have a description.
    #An item can have a picture.

    # generate getter and setter for name and price
    attr_accessor :name, :price, :active, :owner, :id, :description, :picture

    # factory method (constructor) on the class
    def self.created( name, price, owner )
      #Preconditions
      fail "Item needs a name." if (name == nil)
      fail "Item needs a price." if (price == nil)
      fail "Item needs an owner." if (owner == nil)
      item = self.new
      item.id = nil
      item.name = name
      item.price = price
      item.active = false
      item.owner = owner
      item.picture = "../images/items/default_item.png"
      item
    end

    def save
      Models::System.instance.add_item(self)
    end

    # get state
    def is_active?
      self.active
    end

    # set owner
    def set_owner(new_owner)
      self.owner = new_owner
    end

    # to String-method
    def to_s
      "#{self.get_name}, #{self.get_price}"
    end

    # to set active
    def to_active
      self.active = true
    end

    # to set inactive
    def to_inactive
      self.active = false
    end

    # get name
    def get_name
      # string interpolation
      "#{name}"
    end

    # get price
    def get_price
      # int interpolation
      self.price
    end

    # return the owner
    def get_owner
      self.owner
    end

    def self.get_item(itemid)
      return @@item_list[itemid]
    end

    #def self.get_all(viewer)
    #  return @@item_list.select {|s| s.owner.name !=  viewer}
    #end
    def self.get_all(viewer)
      new_array = @@item_list.to_a
      ret_array = Array.new
      for e in new_array
        ret_array.push(e[1])
      end
      ret = ret_array.select {|s| s.owner.name !=  viewer}
      return ret.select {|s| s.is_active?}
    end

    # Adds a decription to the item.
    # @param  description   the string containing the description for the item
    def add_description (description)
      fail "Missing description." if (description == nil)
      self.description = description
    end

    # Adds a path to a picture to the item.
    # @param  picture : path to picture file for the item
    def add_picture (picture)
      fail "Missing picture." if (picture == nil)
      path = Helpers::absolute_path(picture.sub("images", "public/images"), __FILE__)
      fail "There exists no file on path #{path}" unless (File.exists?(path))

      self.picture = picture
    end

    # Checks if an item's attributes can be changed depending on its state.
    # @@return    true if state of the item is active;
    #             false otherwise.
    def editable?
      self.is_active?
    end

    #Removes itself from the list of items and of the system
    def clear
      @@item_list["#{self.id}.#{self.name}"].owner.delete_item(self)
      @@item_list.delete("#{self.id}.#{self.name}")
    end

    #Returns the uniq id if the item
    def get_id
      return "#{self.id}.#{self.name}"
    end

  end

end
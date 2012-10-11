require 'rubygems'
require 'bcrypt'
require 'require_relative'
require_relative('item')
require_relative('../helpers/render')

include Helpers

module Models
  class User
    #Users have a name, a unique e-mail, a description and a avatar.
    #Users have an amount of credits.
    #A new user has originally 100 credit.
    #A user can add a new item to the system with a name and a price; the item is originally inactive.
    #A user provides a method that lists his/her active items to sell.
    #User possesses certain items
    #A user can buy active items of another user (inactive items can't be bought). When a user buys an item, it becomes
    #  the owner; credit are transferred accordingly; immediately after the trade, the item is inactive. The transaction
    #  fails if the buyer has not enough credits.

    # generate getter and setter for name and price
    attr_accessor :description, :avatar, :email, :name, :credits, :item_list, :pw, :password_hash, :password_salt

    ##
    #
    # E-Mailadress should be unique
    #
    ##

    def invariant
      fail "E-mail should be unique" if @@users.one? {|user| @@users.all? {|innerUser| user[1].email != innerUser[1].email if innerUser != user}}
    end

    @@users = {}

    def self.email_unique?(email_to_compare)
      @@users.all? {|user| user[1].email != email_to_compare }
    end

    # factory method (constructor) on the class
    # You have to save the picture at public/images/users/ before
    # you call this method. If not it will fail.
    def self.created(name,  password, email, description, avatar)
      # Preconditions
      fail "Missing name" if (name == nil)
      fail "Missing password" if (password == nil)
      fail "Missing email" if (email == nil)
      fail "Missing description" if (description == nil)
      fail "Missing path to avatar" if (avatar == nil)
      fail "There's no avatar at #{avatar}" unless (File.exists?(Helpers::absolute_path(avatar.sub("images", "public/images"), __FILE__)))
      fail "Not a correct email address" unless email =~ /[A-Za-z123456789._-]+@[A-Za-z123456789-]+\.[a-z]+$/
      fail "E-mail not unique" unless self.email_unique?(email)

      user = self.new
      user.name = name
      user.email = email
      user.description = description
      user.avatar = avatar
      user.credits = 100
      user.item_list = Array.new
      pw_salt = BCrypt::Engine.generate_salt
      pw_hash = BCrypt::Engine.hash_secret(password, pw_salt)
      user.password_salt = pw_salt
      user.password_hash = pw_hash
      user.save

      user.invariant
      user
    end

    def save
      fail "Duplicated user" if @@users.has_key? self.name and @@users[self.name] != self
      @@users[self.name] = self
    end


    #get string representation
    def to_s
      "#{self.name} has currently #{self.credits} credits, #{list_items.size} active and #{list_items_inactive.size} inactive items"
    end

    #return users item list active
    def list_items
      item_list.select {|s| s.is_active?}
    end

    #return users item list inactive
    def list_items_inactive
      item_list.select {|s| !s.is_active?}
    end

    ##
    #
    # Returns true if a user owns a specific item
    #
    ##

    def has_item?(item_name)
      item_list.one? { |item| item.name == item_name }
    end

    ##
    #
    # Returns item with the given name. Throws error if
    # User doesn't own item.
    #
    ##

    def get_item(item_name)
      fail "User doesn't own object \'#{item_name}\'" unless (self.has_item?(item_name))

      item_list.select { |item| item.name == item_name }[0]
    end



    # removing item from users item_list
    def remove_item(item_to_remove)
      self.credits = self.credits + item_to_remove.get_price
      self.item_list.delete(item_to_remove)
    end

    # removing item from users item_list
    def delete_item(item_to_remove)
      self.item_list.delete(item_to_remove)
    end

    def self.login name, password
      return false unless @@users.has_key? name

      user = @@users[name]
      user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
    end

    def self.get_user(username)
      puts @@users
      return @@users[username]
    end

    def self.get_all(viewer)
      new_array = @@users.to_a
      ret_array = Array.new
      for e in new_array
        ret_array.push(e[1])
      end
      return ret_array.select {|s| s.name !=  viewer}
    end


  end
end
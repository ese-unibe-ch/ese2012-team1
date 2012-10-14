require 'rubygems'
require 'bcrypt'
require 'require_relative'
require_relative('item')
require_relative('account')
require_relative('system')
require_relative('organisation')
require_relative('../helpers/render')
require_relative('../helpers/string_checkers')


module Models
  class User < Models::Account
    #Users have a name, an unique e-mail, a description and an avatar.
    #Users have an amount of credits.
    #A new user has originally 100 credits.
    #An user can add a new item to the system with a name and a price; the item is originally inactive.
    #An user provides a method that lists his/her active items to sell.
    #User possesses certain items
    #An user can buy active items of another user (inactive items can't be bought). If an user buys an item, it becomes
    #  the owner; credits are transferred accordingly; immediately after the trade, the item is inactive. The transaction
    #  fails if the buyer has not enough credits.

    # generate getter and setter for name and price
    attr_accessor :email, :pw, :password_hash, :password_salt

    ##
    #
    # E-Mailaddress should be unique
    #
    ##

    def self.email_unique?(email_to_compare)
      (Models::System.instance.users.member?(email_to_compare)) ? false : true
    end

    # factory method (constructor) on the class
    # You have to save the picture at public/images/users/ before
    # you call this method. If not, it will fail.
    def self.created(name,  password, email, description, avatar)
      # Preconditions
      fail "Missing name" if (name == nil)
      fail "Missing password" if (password == nil)
      fail "Missing email" if (email == nil)
      fail "Missing description" if (description == nil)
      fail "Missing path to avatar" if (avatar == nil)
#      fail "There's no avatar at #{avatar}" unless (File.exists?(Helpers::absolute_path(avatar.sub("images", "public/images"), __FILE__)))
      fail "Not a correct email address" unless email.is_email?
#      fail "E-mail not unique" unless self.email_unique?(email)

      user = super(name, description, avatar)

      user.email = email
      pw_salt = BCrypt::Engine.generate_salt
      pw_hash = BCrypt::Engine.hash_secret(password, pw_salt)
      user.password_salt = pw_salt
      user.password_hash = pw_hash

      puts(user)
      puts(user.class)

      user
    end

    def save
      puts("saved!")
      puts(self)
      Models::System.instance.add_account(self)
    end

    #return user's item list active
    # @param user_mail
    def list_items
      Models::System.instance.fetch_items_of(self.id).select { |s| s.is_active? }
    end

    #return user's item list inactive
    def list_items_inactive
      Models::System.instance.fetch_items_of(self.id).select {|s| !s.is_active?}
    end

    ##
    #
    # Returns true if an user owns a specific item
    #
    ##

    def has_item?(itemId)
      Models::System.instance.fetch_items_of(self.id).one? { |item| item.id == itemId.to_i }
    end

    ##
    #
    # Returns item with the given name. Throws error if
    # user doesn't own the item.
    #
    ##

    def get_item(item_Id)
      fail "#{self.email} doesn't own object: \'#{item_Id}\'" unless (self.has_item?(item_Id.to_i))

      Models::System.instance.fetch_item(item_Id)
    end

    def self.login account, password
      return false unless Models::System.instance.accounts.one? { |id, user| user.respond_to?(:email) && user == account }
      user = Models::System.instance.fetch_account(account.id)
      user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
    end

    #Removes himself from the list of users and of the Models::System
    #Removes user's items beforehand
    def clear
      Models::System.instance.fetch_items_of(self.email).each { |e| Models::System.instance.remove_item(e) }
      Models::System.instance.remove_user(self.email)
    end

    # Allows the user to create an organisation of which he automatically becomes the admin.
    # @param name   the name of the organisation
    # @param description    the description of the organisation
    # @return new_organization    the organisation which was created
    # @param picture : picture of the organisation
    def create_organisation(name, description, picture)
      Models::Organisation.created(name, description, picture)
    end


  end
end
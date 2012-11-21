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
    attr_accessor :email, :pw, :password_hash, :password_salt, :activated, :reg_hash

    ##
    #
    # E-Mailaddress should be unique
    #
    ##

    def invariant
      Models::System.instance.fetch_user_by_email(self.email) == self
    end

    # factory method (constructor) on the class
    # You have to save the avatar at public/images/users/ before
    # you call this method. If not, it will fail.
    def self.created(name,  password, email, description, avatar)
      # Preconditions
      fail "Missing name" if (name == nil)
      fail "Missing password" if (password == nil)
      fail "Missing email" if (email == nil)
      fail "Missing description" if (description == nil)
      fail "Missing path to avatar" if (avatar == nil)
      fail "There's no avatar at #{avatar}" unless (File.exists?(Helpers::absolute_path(avatar.sub("/images", "../public/images"), __FILE__)))
      fail "Not a correct email address" unless email.is_email?
      fail "E-mail not unique" if Models::System.instance.user_exists?(email)

      user = super(name, description, avatar)

      user.email = email
      pw_salt = BCrypt::Engine.generate_salt
      pw_hash = BCrypt::Engine.hash_secret(password, pw_salt)
      rg_hash = BCrypt::Engine.hash_secret("#{user.name}.#{user.email}.#{user.description}", pw_salt)
      user.password_salt = pw_salt
      user.password_hash = pw_hash
      user.reg_hash = rg_hash.gsub("/", "")
      user.activated = false

      user
    end

    def login password
      self.password_hash == BCrypt::Engine.hash_secret(password, self.password_salt)
    end

    def activate
      self.activated=true
    end

    #Removes himself from the list of users of the Models::System
    #Removes his avatar (not yet implemented)
    #Removes user's items beforehand
    #TODO test if admin by init works
    def clear
      Models::System.instance.fetch_items_of(self.id).each { |e| e.clear }
      Models::System.instance.remove_account(self.id)

      unless (self.avatar == "/images/users/default_avatar.png")
        File.delete("#{self.avatar.sub("/images", "./public/images")}")
      end
    end

    # Allows the user to create an organisation of which he automatically becomes the admin.
    # @param name   the name of the organisation
    # @param description    the description of the organisation
    # @return new_organization    the organisation which was created
    # @param avatar : avatar of the organisation
    def create_organisation(name, description, avatar)
      # Preconditions
      fail "Missing name" if (name == nil)
      fail "Missing description" if (description == nil)
      fail "Missing avatar path" if (avatar == nil)
      org = Models::Organisation.created(name, description, avatar)
      org.organisation = true
      org.add_member(self)
      org.set_as_admin(self)
      org
    end

    #TODO tests
    def is_last_admin_of?(organisation)
      #Precondition
      fail "Missing organisation to check" if (organisation == nil)
      organisation.is_admin?(self) && organisation.size == 1
    end

    #TODO tests
    def is_last_admin?
      organisations = Models::System.fetch_organisations_of(self.id)
      organisations.one? { |organisation| self.is_last_admin_of?(organisation)}
    end

    def password(password)
      # Precondition
      fail "Missing password" if (password == nil)
      pw_salt = BCrypt::Engine.generate_salt
      pw_hash = BCrypt::Engine.hash_secret(password, pw_salt)
      self.password_salt = pw_salt
      self.password_hash = pw_hash
    end
  end
end
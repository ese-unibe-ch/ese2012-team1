module Models
 class Organisation < Models::Account
    ##
    #
    # An Organisation is an account which is accessed by multiple users (member).
    # Users with certain rights (admin) may add and remove members of an organisation.
    # Every user in the users list can act as the organisation and buy or sell items for it.
    # Organisations may own certain items.
    # Organisations (represented by the users in the list) may buy and sell  items of another user or organisation
    # The limit of each member is reseted at 23:59 to the organisation limit.
    #
    # members : a hashmap with all email addresses and users of an organisation
    # admins : a part of members that contains only the admins
    # limit : the maximum amount of credits non-admins can spend per day
    # member_limits : a hashmap with email address of all members and their rest limit
    #
    ##

    attr_accessor :members, :admins, :limit, :member_limits


    ##
    #
    # Creates all hashmaps and sets no limit.
    # Creates a searchitem for the organisation
    # and adds it to the system
    #
    ##
    def initialize
      super
      self.members = Hash.new
      self.admins = Hash.new
      self.member_limits = Hash.new #the remaining limit of each user
      self.limit = nil #with limit=nil everybody can spend as much as they want
      self.organisation = true

      System.instance.search.register(SearchItemOrganisation.create(self, "organisation", [:name, :description]))
    end

    ##
    #
    # Adds a user to the organisation by adding him to the member- and the limithashmap
    #
    # Expects :
    # user : the user who should be added to the org.
    #
    ##
    def add_member(user)
      self.member_limits.store(user.email, self.limit)
      self.members.store(user.email, user)
    end

    ##
    #
    # Removes a user from the organisation by deleting him from the member- , limit-
    # and if needed from the adminhashmap
    #
    # Expects :
    # user : the user who should be removed from the org.
    #
    ##
    def remove_member(user)
      self.member_limits.delete(user.email)
      self.members.delete(user.email)
      self.admins.delete(user.email) if self.is_admin?(user)
    end

    ##
    #
    # Removes a user from the organisation by deleting him from the member- , limit-
    # and if needed from the adminhashmap
    #
    # Expects :
    # user_mail : the email of the user who should be removed from the org.
    #
    ##
    def remove_member_by_email(user_mail)
      self.members.delete(user_mail)
      self.member_limits.delete(user_mail)
      self.admins.delete(user_mail) if self.admins.one? { |email, admin| email == user_mail }
    end

    ##
    #
    # Determines if a specific user is a member of this organisation.
    #
    # Expects :
    # user : user who should be checked
    #
    ##
    def is_member?(user)
      self.members.one? { |email, member| email == user.email }
    end

    ##
    #
    # Gets all non-admin memebers of this organisation
    #
    ##
    def members_without_admins
      self.members.values.select { |member| !self.is_admin?(member) }
    end

    ##
    #
    # Determines if a specific user is an admin in this organisation.
    #
    # Expects :
    # user : user who should be checked
    #
    ##
    def is_admin?(user)
      self.admins.one? { |email, admin| email == user.email }
    end

    ##
    #
    # Returns how many admins are in this organisation
    #
    ##
    def admin_count
      admins.size
    end

    ##
    #
    # Promotes a regular member to an admin
    #
    # Expects :
    # member : the member who becomes an admin
    #
    ##
    def set_as_admin(member)
#      fail "#{member.email} is not a member of this organisation" unless members[member.email]
      self.admins.store(member.email, member)
    end

    ##
    #
    # Degrades an admin to a regular member
    # Fails if member is the last admin in this org. or
    # if he is no admin
    #
    # Expects :
    # member : the admin who will be degraded
    #
    ##
    def revoke_admin_rights(member)
      fail "#{member.email} is not a admin of this organisation" unless admins[member.email]
      fail "not enough admins left" unless self.admin_count > 1
      self.admins.delete(member.email)
    end

    ##
    #
    # Lets a member of the org. buy an item on behalf of this
    # organisation. Transfers credits to the owner of this item
    # and subtracts the same amount from the organisation.
    # Sets the new owner of the item to his organisation.
    #
    # Fails if the price of the item would exceed
    # the limit of user, if the org. doesn't have enough money, or
    # if the item couldn't be found.
    #
    # Expects :
    # item_to_buy : the item who user wants to buy
    # user : the user who buys this item on behalf of this
    #        organisation
    #
    ##
    def buy_item(item_to_buy, user)
      fail "only users can buy items in behalve of an organisation" if (user.organisation)
      fail "only users that are part of #{self.name} can buy items for it" unless (is_member?(user))
      fail "would exceed #{user.name}'s organisation limit for today" unless within_limit_of?(item_to_buy, user)
      fail "not enough credits" if item_to_buy.price > self.credits
      fail "Item not in System" unless (DAOItem.instance.item_exists?(item_to_buy.id))

      old_owner = item_to_buy.owner

      #Subtracts price from buyer
      self.credits = self.credits - item_to_buy.price
      #Adds price to owner
      old_owner.credits += item_to_buy.price
      #decreases the limit of the buyer
      member_limits[user.email]=self.member_limits.fetch(user.email)-item_to_buy.price unless self.limit.nil? || is_admin?(user)

      item_to_buy.bought_by(self)
    end

    ##
    #
    # Returns the limit of a specific user
    #
    # Expects :
    # user : the user whose limit you want to know
    #
    ##
    def get_limit(user)
      self.member_limits.fetch(user.email)
    end

    ##
    #
    # Checks if item can be bought by user with his
    # current limit. Returns always true if user is
    # an admin or the limit is nil.
    #
    # Expects :
    # item : the item that user wants to buy
    # user : the user whose limit is checked
    #
    ##
    def within_limit_of?(item, user)
      is_admin?(user) or self.limit.nil? or self.member_limits.fetch(user.email)>=item.price
    end

    ##
    #
    # Changes the limit of this organisation.
    # it can't be less than 0
    #
    # Expects :
    # amount : the new limit
    #
    ##
    def set_limit(amount)
      fail "no valid limit" if amount<0
      self.limit=amount
    end

    ##
    #
    # Sets the limit of a specific user to
    # the desired amount.
    #
    # Expects :
    # user : the user whose limit is changed
    # amount : the new limit of this user
    #
    ##
    def set_member_limit(user,amount)
      fail "no valid limit" if amount<0
      member_limits[user.email]=amount
    end

    ##
    #
    # Resets the limit of each user to the organisation
    # limit
    #
    ##
    def reset_member_limits
      member_limits.each do |user, limit|
        member_limits[user]=self.limit
      end
    end

    ##
    #
    # Removes the organisation from the system
    # TODO: This does nothing at all...
    #
    ##
    def clear
      System.search.unregister(self)
    end
  end
end
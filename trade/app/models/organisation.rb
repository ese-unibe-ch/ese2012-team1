module Models
  ##
  #
  # An Organisation is an account which is accessed by multiple users (member).
  # Users with certain rights (admin) may add and remove members of an organisation.
  # Every user in the users list can act as the organisation and buy or sell items for it.
  # Organisations may own certain items.
  # Organisations (represented by the users in the list) may buy and sell items of another user or organisation.
  # It is possible to set a limit so normal user can only buy items to a certain amount.
  # The limit of each member is reseted at 23:59 to the organisation limit.
  #
  # +members+:: a hashmap with all email addresses and users of an organisation
  # +admins+:: a part of members that contains only the admins
  # +limit+:: the maximum amount of credits non-admins can spend per day
  # +member_limits+:: a hashmap with email address of all members and their rest limit
  #
  ##

  class Organisation < Models::Account
    attr_accessor :members, :admins, :limit

    @member_limits


    class Limit
      # money the user spend until now
      attr_accessor :spend
      # user that belongs to this limit
      attr_accessor :user
      # the organisation this limit belongs to
      attr_accessor  :organisation

      def initialize
        @spend = 0
        @user = nil
        @organisation = nil
      end

      ##
      #
      # Factory method to create a Limit
      #
      # === Parameters
      #
      # +user+:: the user the limit is for
      # +organisation+:: the organisation this limit belongs
      #
      ##

      def self.create(user, organisation)
        limit = Limit.new
        limit.user = user
        limit.organisation = organisation
        limit
      end

      ##
      #
      # Adds new amount to the amount the user
      # already has spend.
      #
      # +amount+:: amount to add
      #
      ##

      def spend(amount)
        @spend += amount
      end

      ##
      #
      # Calculates the limit for the user. This calculation
      # is based on the amount of money the user has spend.
      # Returns 0 if the user can't spend any money anymore.
      # If the user is an administrator or the limit of the
      # organisation is nil. He can spend as much money as he
      # he wants and this method returns nil to indicate this.
      #
      ##

      def limit
        if @organisation.is_admin?(@user) || @organisation.limit.nil?
            nil
        else
          resources =  @organisation.limit - @spend
          resources < 0 ? 0 : resources
        end
      end

      ##
      #
      # Returns true if the price is within the range of the users
      # limit and he can buy it without succeding his limit.
      # Returns false otherwise.
      #
      # ===Parameters
      #
      # +price+:: price the user wants to spend
      #
      ##

      def has_resources_for?(price)
        return true if @organisation.limit.nil? || @organisation.is_admin?(@user)

        resources =  @organisation.limit - (@spend + price)
        resources > 0
      end

      ##
      #
      # Resets the amount spended. After this #limit returns exactly the
      # limit of the organisation
      #
      ##

      def reset
        @spend = 0
      end
    end

    ##
    #
    # Creates all hash maps and sets limit to nil (ergo no limit at all).
    # Creates a SearchItem for the organisation and adds it to the Search..
    # Sets +organisation+ to true to indicate that this is a organisation.
    #
    ##
    def initialize
      super
      self.members = Hash.new
      self.admins = Hash.new
      @member_limits = Hash.new #the remaining limit of each user
      self.limit = nil #with limit=nil everybody can spend as much as they want
      self.organisation = true

      System.instance.search.register(SearchItemOrganisation.create(self, "organisation", [:name, :description]))
    end

    ##
    #
    # Adds a user to the organisation by adding him to the member
    # and the limits hash map
    #
    # === Parameters
    #
    # +user+:: the user who should be added to the org.
    #
    ##
    def add_member(user)
      fail "missing user" if user.nil?

      @member_limits.store(user.email, Limit.create(user, self))
      self.members.store(user.email, user)
    end

    ##
    #
    # Removes a user from the organisation by deleting him from the member, limit
    # and if needed from the admin hash map
    #
    # === Parameters
    #
    # +user+:: the user who should be removed from the org (can't be last admin of organisation).
    #
    ##
    def remove_member(user)
      fail "not enough admins left" if self.is_last_admin?(user)

      @member_limits.delete(user.email)
      self.members.delete(user.email)
      self.admins.delete(user.email) if self.is_admin?(user)
    end

    ##
    #
    # Determines if a specific user is a member of this organisation.
    #
    # Returns true if user is a member, false otherwise.
    #
    # === Parameters
    #
    # +user+:: user who should be checked
    #
    ##
    def is_member?(user)
      self.members.one? { |email, member| email == user.email }
    end

    ##
    #
    # Gets all non-admin members of this organisation
    #
    # Returns an array of all non-admin members
    #
    ##
    def members_without_admins
      self.members.values.select { |member| !self.is_admin?(member) }
    end

    ##
    #
    # Determines if a specific user is an admin in this organisation.
    #
    # Returns true if user is admin, false otherwise
    #
    # === Parameters
    #
    # +user+:: user who should be checked
    #
    ##
    def is_admin?(user)
      self.admins.one? { |email, admin| email == user.email }
    end

    ##
    #
    # Counts how many admins are in this organisation
    #
    # Returns the number of admins as Integer
    #
    ##
    def admin_count
      admins.size
    end

    ##
    #
    # Promotes a regular member to an admin
    #
    # === Parameters
    #
    # +member+:: the member who becomes an admin (must be member of this organisation and can't be already admin)
    #
    ##
    def set_as_admin(member)
      fail "#{member.email} is not a member of this organisation" unless is_member?(member)
      fail "#{member.email} is already admin" if is_admin?(member)

      self.admins.store(member.email, member)
    end

    ##
    #
    # Degrades an admin to a regular member
    #
    # Fails if member is the last admin in this org. or
    # if he is no admin
    #
    # === Parameters
    #
    # +member+:: the admin who will be degraded (must be admin of this organisation and can't be last admin)
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
    # === Parameters
    #
    # +item_to_buy+:: the item who user wants to buy
    # +user+:: the user who buys this item on behalf of this
    #          organisation
    #
    ##
    def buy_item(item_to_buy, user)
      fail "only users can buy items in behalve of an organisation" if (user.organisation)
      fail "only users that are part of #{self.name} can buy items for it" unless (is_member?(user))
      fail "would exceed #{user.email}'s organisation limit for today" unless within_limit_of?(item_to_buy, user)
      fail "not enough credits" if item_to_buy.price > self.credits
      fail "Item not in System" unless (DAOItem.instance.item_exists?(item_to_buy.id))

      old_owner = item_to_buy.owner

      #Subtracts price from buyer
      self.credits = self.credits - item_to_buy.price
      #Adds price to owner
      old_owner.credits += item_to_buy.price
      #decreases the limit of the buyer
      @member_limits[user.email].spend(item_to_buy.price) unless self.limit.nil? || is_admin?(user)

      item_to_buy.bought_by(self)
    end

    ##
    #
    # Checks if given user is the last admin.
    #
    # Returns true if user is las admin, false
    # otherwise.
    #
    # +user+:: User to be checked
    #
    ##
    def is_last_admin?(user)
      fail "Missing user" if (user == nil)

      is_admin?(user) && self.admin_count == 1
    end

    ##
    #
    # Returns the limit of a specific user
    # as Integer
    #
    # === Parameters
    #
    # +user+:: the user whose limit you want to know (can't be nil)
    #
    ##
    def get_limit(user)
      fail "missing user" if user.nil?

      @member_limits.fetch(user.email).limit
    end

    ##
    #
    # Checks if item can be bought by user with his
    # current limit.
    #
    # Returns true if user has enough resources to
    # buy this item, false otherwise.
    #
    # Returns always true if user is
    # an admin or the limit is nil.
    #
    # === Parameters
    #
    # +item+:: the item that user wants to buy
    # +user+:: the user whose limit is to be checked
    #
    ##
    def within_limit_of?(item, user)
      @member_limits.fetch(user.email).has_resources_for?(item.price)
    end

    ##
    #
    # Changes the limit of this organisation.
    #
    # === Parameters
    #
    # +amount+:: the new limit (can't be nil or less than zero)
    #
    ##
    def set_limit(amount)
      fail "no valid limit" if !amount.nil? && amount<0

      self.limit=amount.to_i
    end

    ##
    #
    # Resets the limit of each user to the organisation
    # limit
    #
    ##
    def reset_member_limits
      @member_limits.each do |user, limit|
        limit.reset
      end
    end

    ##
    #
    #  Removes user from the list of users of the DAOAccount,
    #  deletes his avatar, removes user's items from DAOItem and
    #  unregisters himself from Search
    #
    ##
    def clear
      System.search.unregister(self)

      DAOItem.instance.fetch_items_of(self.id).each { |e| e.clear }
      DAOAccount.instance.remove_account(self.id)

      unless (account.avatar == "/images/organisations/default_avatar.png")
        File.delete("#{account.avatar.sub("/images", "./public/images")}")
      end
    end
  end
end
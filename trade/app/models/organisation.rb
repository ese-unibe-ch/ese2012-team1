module Models
 class Organisation < Models::Account
    #An Organisation is an account which is accessed by multiple users (member).
    # Users with certain rights (admin) may add and remove members of an organisation.
    #every user in the users list can act as the organisation and buy or sell items for it.
    #Accounts have a name, an amount of credits, a description, an avatar and a list of users.
    #organisations may own certain items
    #organisations (represented by the users in the list) may buy and sell  items of another user or organisation

    # generate getter and setter
    attr_accessor :members, :admins, :limit, :member_limits

    def initialize
      super
      self.members = Hash.new
      self.admins = Hash.new
      self.member_limits = Hash.new #the remaining limit of each user
      self.limit = 30 #with limit=nil everybody can spend as much as they want

      System.instance.search.register(SearchItemOrganisation.create(self, "organisation", [:name, :description]))
    end

    def add_member(user)
      self.member_limits.store(user.email, self.limit)
      self.members.store(user.email, user)
    end

    def remove_member(user)
      self.member_limits.delete(user.email)
      self.members.delete(user.email)
      self.admins.delete(user.email) if self.is_admin?(user)
    end

    def remove_member_by_email(user_mail)
      self.members.delete(user_mail)
      self.member_limits.delete(user_mail)
      self.admins.delete(user_mail) if self.admins.one? { |email, admin| email == user_mail }
    end

    def is_member?(user)
      self.members.one? { |email, member| email == user.email }
    end

    def members_without_admins
      self.members.values.select { |member| !self.is_admin?(member) }
    end

    def is_admin?(user)
      self.admins.one? { |email, admin| email == user.email }
    end

    def admin_count
      admins.size
    end

    def set_as_admin(member)
#      fail "#{member.email} is not a member of this organisation" unless members[member.email]
      self.admins.store(member.email, member)
    end

    def revoke_admin_rights(member)
      fail "#{member.email} is not a admin of this organisation" unless admins[member.email]
      fail "not enough admins left" unless self.admin_count > 1
      self.admins.delete(member.email)
    end

    def buy_item(item_to_buy, user)
      fail "would exceed #{user.email}'s organisation limit for today" unless within_limit_of?(item_to_buy, user)
      fail "not enough credits" if item_to_buy.price > self.credits
      fail "Item not in System" unless (System.instance.items.include?(item_to_buy.id))
      # PZ: Don't like that I can't do that:
      # fail "Item already belongs to you" if (System.instance.fetch_items_of(self.id))

      old_owner = item_to_buy.owner

      #Subtracts price from buyer
      self.credits = self.credits - item_to_buy.price
      #Adds price to owner
      old_owner.credits += item_to_buy.price
      #decreases the limit of the buyer
      member_limits[user.email]=self.member_limits.fetch(user.email)-item_to_buy.price unless self.limit.nil?

      item_to_buy.bought_by(self)
    end

    def within_limit_of?(item, user)
      is_admin?(user) or self.limit.nil? or self.member_limits.fetch(user.email)>=item.price
    end

    def set_limit(amount)
      fail "no valid limit" if amount<0
      self.limit=amount
    end

    def set_member_limit(user,amount)
      member_limits[user.email]=amount
    end

    #Not sure if this works
    def reset_member_limits
      member_limits.each do |user, limit|
        member_limits[user]=self.limit
      end
    end

    def clear
      System.search.unregister(self)
    end

  end
end
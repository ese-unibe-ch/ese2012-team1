require 'rubygems'
require 'require_relative'

require_relative('search_item_organisation')
require_relative('account')
require_relative('system')

module Models
 class Organisation < Models::Account
    #An Organisation is an account which is accessed by multiple users (member).
    # Users with certain rights (admin) may add and remove members of an organisation.
    #every user in the users list can act as the organisation and buy or sell items for it.
    #Accounts have a name, an amount of credits, a description, an avatar and a list of users.
    #organisations may own certain items
    #organisations (represented by the users in the list) may buy and sell  items of another user or organisation

    # generate getter and setter
    attr_accessor :members, :admins

    def initialize
      super
      self.members = Hash.new
      self.admins = Hash.new

      System.instance.search.register(SearchItemOrganisation.create(self, "organisation", [:name, :description]))
    end

    def add_member(user)
      self.members.store(user.email, user)
    end

    def remove_member(user)
      self.members.delete(user.email)
      self.admins.delete(user.email) if self.is_admin?(user)
    end

    def remove_member_by_email(user_mail)
      self.members.delete(user_mail)
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

    def clear
      System.search.unregister(self)
    end

  end
end
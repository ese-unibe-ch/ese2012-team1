require 'rubygems'
require 'bcrypt'
require 'require_relative'
require_relative('item')
require_relative('account')
require_relative('system')

=begin
module Models
 class Organisation < Models::Account
    #An Organisation is an account witch is accessed by multiple users.
    #every user in the users list can act as the organisation and buy or sell items for it
    #Accounts have a name, an amount of credits, a description, an avatar and a list of users.
    #organisations may own certain items
    #organisations (represented trough the users in the list) may buy and sell  items of another users or organisations


    # generate getter and setter
    attr_accessor :users

    def is_member?(user)
      users.one? { |member| member.email == user.email }
    end

    def self.named(name, desc, pic, user)
      org = self.new
      org.name = name
      org.description = desc
      org.avatar = pic
      org.users = Array.new
      org.users.push(user)
      org.save
    end

    def save
      Models::System.instance.add_organisation(self)
    end

    def get_name
      self.name
    end
  end
end
=end
module Model
  class Organisation < Models::Account
    #An Organisation is an account witch is accessed by multiple users.
    #every user in the users list can act as the organisation and buy or sell items for it
    #Accounts have a name, an amount of credits, a description, an avatar and a list of users.
    #organisations may own certain items
    #organisations (represented trough the users in the list) may buy and sell  items of another users or organisations


    # generate getter and setter
    attr_accessor :users
  end

  def is_Member?(user)
    users.one? { |member| member.email == user.email }
  end

  def self.named(name, desc, pic, user)
    org = self.new
    org.name = name
    org.description = desc
    org.avatar = pic
    org.users = List.new
    org.users.add(user)
    Model:System.organisation.add(self)
  end

end
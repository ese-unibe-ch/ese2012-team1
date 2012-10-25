require 'rubygems'
require 'require_relative'
require_relative('../../trade/app/models/item')
require_relative('../../trade/app/models/user')

include Models

userA = Models::User.created( "userA", "passwordA", "userA@mail.ch", "I'm User A", "/images/users/default_avatar.png")
aa = userA.create_item("UserA_ItemA", 10)
ab = userA.create_item("UserA_ItemB", 50)
ab.to_active
ac = userA.create_item("UserA_ItemC", 120)
ac.to_active

userB = Models::User.created( "userB", "passwordB", "userB@mail.ch", "I'm User B", "/images/users/default_avatar.png")
ba = userB.create_item("UserB_ItemA", 10)
ba.to_active
bb = userB.create_item("UserB_ItemB", 50)
bb.to_active
bc = userB.create_item("UserB_ItemC", 120)

userC = Models::User.created( "userC", "passwordC", "userC@mail.ch", "I'm User C", "/images/users/default_avatar.png")
ca = userC.create_item("UserC_ItemA", 10)
ca.to_active
cb = userC.create_item("UserC_ItemB", 50)
cc = userC.create_item("UserC_ItemC", 120)
cc.to_active

ese = Models::User.created( "ese", "ese" , "ese@mail.ch", "I'm ese", "/images/users/ese.png")

eseOrg = Models::Organisation.created("EseOrg", "a simple Test Organisation","/images/organisations/EseOrg.png" )
eseOrg.add_member(ese)
eseOrg.add_member(userA)
eseOrg.add_member(userB)
eseOrg.add_member(userC)

(68..72).each do |ascii_nr_of_character|
  Models::User.created("user#{ascii_nr_of_character.chr}", "password#{ascii_nr_of_character.chr}" , "user#{ascii_nr_of_character.chr}@mail.ch", "I'm #{ascii_nr_of_character.chr}", "/images/users/default_avatar.png")
end
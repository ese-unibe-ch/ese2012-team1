require 'rubygems'
require 'require_relative'
require_relative('../../trade/app/models/item')
require_relative('../../trade/app/models/user')
require_relative('../../trade/app/models/comment')

include Models

userA = Models::User.created( "userA", "passwordA", "userA@mail.ch", "I'm a food trader!", "/images/users/default_avatar.png")
userA.activate
aa = userA.create_item("cheap red apple", 10)
aa.add_description("a very juicy apple")
ab = userA.create_item("banana", 50)
ab.add_description("a very fine one!")
ab.to_active
ac = userA.create_item("orange", 120)
ac.add_description("a cheap but very orange orange")
ac.to_active

userB = Models::User.created( "userB", "passwordB", "userB@mail.ch", "I'm a furniture trader", "/images/users/default_avatar.png")
userB.activate
ba = userB.create_item("seat", 10)
ba.add_description("it's very comfortable and hardly never used")
ba.to_active
bb = userB.create_item("sofa", 50)
bb.to_active
bc = userB.create_item("table", 120)
bc.add_description("this table has four legs. buy it! it's very cheap!")

userC = Models::User.created( "userC", "passwordC", "userC@mail.ch", "I'm a money trader", "/images/users/default_avatar.png")
userC.activate
ca = userC.create_item("us dollar", 10)
ca.to_active
cb = userC.create_item("yen", 50)
cc = userC.create_item("swiss franc", 120)
cc.to_active

ese = Models::User.created( "ese", "ese" , "ese@mail.ch", "I'm ese", "/images/users/ese.png")
ese.activate
ese.create_item("ESE_Item1", 20)
eseitem = ese.create_item("ESE_Item2", 20)
eseitem.to_active

comment = Comment.create(userC, "I love it!", "I love that Item! And I love to write a lot. And I still write things nobody cares about. I don't even care. I just have to write a very very very long text so I can check if this works as well. It is still a bit too short because I can still not see what happens if it is bigger than the user_info. Now it should work!")
eseitem.add(comment)
comment.add(Comment.create(userB, "Yap!", "That's true. Best I've ever had!"))

eseOrg = Models::Organisation.created("EseOrg", "a simple Test Organisation","/images/organisations/EseOrg.png" )
eseOrg.organisation = true
eseOrg.add_member(ese)
eseOrg.set_as_admin(ese)
eseOrg.add_member(userA)
eseOrg.add_member(userB)
eseOrg.add_member(userC)
eseOrg.create_item("ESEOrg_Item1", 20)
eseOrgitem = eseOrg.create_item("ESEOrg_Item2", 20)
eseOrgitem.to_active

(68..72).each do |ascii_nr_of_character|
  Models::User.created("user#{ascii_nr_of_character.chr}", "password#{ascii_nr_of_character.chr}" , "user#{ascii_nr_of_character.chr}@mail.ch", "I'm #{ascii_nr_of_character.chr}", "/images/users/default_avatar.png")
end
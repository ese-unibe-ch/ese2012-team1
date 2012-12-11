require 'rubygems'
require 'require_relative'
require_relative('../../trade/app/models/item')
require_relative('../../trade/app/models/user')
require_relative('../../trade/app/models/comment')

include Models

userA = Models::User.created( "userA", "passwordA", "userA@mail.ch", "I'm a food trader!", "/images/users/food.jpg")
userA.activate
aa = userA.create_item("cheap red apple", 10)
aa.add_description("a very juicy apple")
aa.add_picture("/images/items/apple.jpg")

ab = userA.create_item("banana", 50)
ab.add_description("a very fine one!")
ab.add_picture("/images/items/banana.png")
ab.to_active
ac = userA.create_item("orange", 120)
ac.add_description("a cheap but very orange orange")
ac.add_picture("/images/items/orange.jpg")
ac.to_active

userB = Models::User.created( "userB", "passwordB", "userB@mail.ch", "I'm a furniture trader", "/images/users/furniture.jpg")
userB.activate
ba = userB.create_item("chair", 10)
ba.add_description("it's very comfortable and hardly never used")
ba.add_picture("/images/items/chair.jpg")
ba.to_active
bb = userB.create_item("sofa", 50)
bb.add_picture("/images/items/sofa.jpg")
bb.to_active
bc = userB.create_item("table", 120)
bc.add_picture("/images/items/table.gif")
bc.add_description("this table has four legs. buy it! it's very cheap!")

userC = Models::User.created( "userC", "passwordC", "userC@mail.ch", "I'm a money trader", "/images/users/money.jpg")
userC.activate
ca = userC.create_item("us dollar", 10)
ca.add_picture("/images/items/dollar.jpg")
ca.to_active
cb = userC.create_item("yen", 50)
cb.add_picture("/images/items/yen.jpg")
cc = userC.create_item("swiss franc", 120)
cc.add_picture("/images/items/francs.jpg")
cc.to_active

ese = Models::User.created( "ese", "ese" , "ese@mail.ch", "I'm ese", "/images/users/ese.png")
ese.activate
eseitem1 = ese.create_item("BMW M5", 50)
eseitem1.add_picture("/images/items/bmw.jpg")
eseitem = ese.create_item("Fiat 500", 20)
eseitem.add_picture("/images/items/fiat.jpg")
eseitem.to_active

#Add some comments
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
eseOrgItem1 = eseOrg.create_item("Concorde", 20)
eseOrgItem1.add_picture("/images/items/concorde.jpg")
eseOrgItem2 = eseOrg.create_item("Airbus A380", 20)
eseOrgItem2.add_picture("/images/items/a380.jpg")
eseOrgItem2.to_active

(68..72).each do |ascii_nr_of_character|
  Models::User.created("user#{ascii_nr_of_character.chr}", "password#{ascii_nr_of_character.chr}" , "user#{ascii_nr_of_character.chr}@mail.ch", "I'm #{ascii_nr_of_character.chr}", "/images/users/default_avatar.png")
end

#Send some messages
Messenger.instance.new_message(ese.id, [userA.id, userB.id], "Hey there!", "I'm really glad you're on the trading system!")
Messenger.instance.answer_message(userA.id, [ese.id], "Don't like userB", "What do you think about userB? I think he's selling trash...", 1, 1)
Messenger.instance.new_message(userB.id, [ese.id], "Whats up!", "Didn't know you were interested in the trading system. Wanna trade something?")
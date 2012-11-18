class Navigations
  @@navigations = nil
  @@selected = nil

  def self.set
    @@navigations = { :unregistered => Navigation.new, :user => Navigation.new, :organisation => Navigation.new}
    @@selected = @@navigations[:unregistered]

    #Create Navigation for unregistered users
    @@navigations[:unregistered].add_navigation("home", "/home")
    @@navigations[:unregistered].add_navigation("login", "/login")
    @@navigations[:unregistered].add_navigation("register", "/register")

    #Create Navigations for users
    @@navigations[:user].add_navigation("home", "")
    @@navigations[:user].add_navigation("community", "")
    @@navigations[:user].add_navigation("market", "/items/active")
    @@navigations[:user].add_navigation("logout", "/logout")

    @@navigations[:user].select(1)
    @@navigations[:user].add_subnavigation("profile", "/home/user")
    @@navigations[:user].add_subnavigation("organisations", "/organisations/self")
    @@navigations[:user].add_subnavigation("items", "/items/my/all")
    @@navigations[:user].add_subnavigation("edit profile", "/account/edit/user/profile")
    @@navigations[:user].subnavigation.select(1)

    @@navigations[:user].select(2)
    @@navigations[:user].add_subnavigation("users", "/users/all")
    @@navigations[:user].add_subnavigation("organisations", "/organisations/all")
    @@navigations[:user].subnavigation.select(1)

    @@navigations[:user].select(3)
    @@navigations[:user].add_subnavigation("on sale", "/items/active")
    @@navigations[:user].add_subnavigation("create item", "/item/create")
    @@navigations[:user].subnavigation.select(1)

    @@navigations[:user].select(1)

    #Create navigations for organisation

    @@navigations[:organisation].add_navigation("home", "")
    @@navigations[:organisation].add_navigation("community", "")
    @@navigations[:organisation].add_navigation("market", "/items/active")
    @@navigations[:organisation].add_navigation("logout", "/logout")

    @@navigations[:organisation].select(1)
    @@navigations[:organisation].add_subnavigation("profile", "/home/organisation")
    @@navigations[:organisation].add_subnavigation("items", "/items/my/all")
    @@navigations[:organisation].add_subnavigation("members", "/organisation/members")
    @@navigations[:organisation].add_subnavigation("add member", "/organisation/add/member")
    @@navigations[:organisation].add_subnavigation("edit organisation", "/account/edit/organisation/profile")
    @@navigations[:organisation].subnavigation.select(1)

    @@navigations[:organisation].select(2)
    @@navigations[:organisation].add_subnavigation("users", "/users/all")
    @@navigations[:organisation].add_subnavigation("organisations", "/organisations/all")
    @@navigations[:organisation].subnavigation.select(1)

    @@navigations[:organisation].select(3)
    @@navigations[:organisation].add_subnavigation("on sale", "/items/active")
    @@navigations[:organisation].add_subnavigation("create item", "/item/create")
    @@navigations[:organisation].subnavigation.select(1)

    @@navigations[:organisation].select(1)
  end

  def self.select(name_of_navigation)
    @@selected = @@navigations[name_of_navigation]
  end

  def self.get
    @@navigations
  end

  def self.get_selected
    @@selected
  end
end
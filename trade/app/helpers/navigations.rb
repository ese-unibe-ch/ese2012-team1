class Navigations
  attr_accessor :navigations, :selected

  def initialize
    self.navigations = nil
    self.selected = nil
  end
  
  def build
    self.navigations = { :unregistered => Navigation.new, :user => Navigation.new, :organisation => Navigation.new}
    self.selected = self.navigations[:unregistered]

    #Create Navigation for unregistered users
    self.navigations[:unregistered].add_navigation("home", "/home")
    self.navigations[:unregistered].add_navigation("login", "/login")
    self.navigations[:unregistered].add_navigation("register", "/register")

    #Create Navigations for users
    self.navigations[:user].add_navigation("home", "")
    self.navigations[:user].add_navigation("community", "")
    self.navigations[:user].add_navigation("market", "/items/active")
    self.navigations[:user].add_navigation("logout", "/logout")

    self.navigations[:user].select_by_name("home")
    self.navigations[:user].add_subnavigation("profile", "/home/user")
    self.navigations[:user].add_subnavigation("organisations", "/organisations/self")
    self.navigations[:user].add_subnavigation("items", "/items/my/all")
    self.navigations[:user].add_subnavigation("edit profile", "/account/edit/user/profile")
    self.navigations[:user].subnavigation.select_by_name("profile")

    self.navigations[:user].select_by_name("community")
    self.navigations[:user].add_subnavigation("users", "/users/all")
    self.navigations[:user].add_subnavigation("organisations", "/organisations/all")
    self.navigations[:user].subnavigation.select_by_name("users")

    self.navigations[:user].select_by_name("market")
    self.navigations[:user].add_subnavigation("on sale", "/items/active")
    self.navigations[:user].add_subnavigation("create item", "/item/create")
    self.navigations[:user].subnavigation.select_by_name("on sale")

    self.navigations[:user].select_by_name("home")

    #Create navigations for organisation

    self.navigations[:organisation].add_navigation("home", "")
    self.navigations[:organisation].add_navigation("community", "")
    self.navigations[:organisation].add_navigation("market", "/items/active")
    self.navigations[:organisation].add_navigation("logout", "/logout")

    self.navigations[:organisation].select(1)
    self.navigations[:organisation].add_subnavigation("profile", "/home/organisation")
    self.navigations[:organisation].add_subnavigation("items", "/items/my/all")
    self.navigations[:organisation].add_subnavigation("members", "/organisation/members")
    self.navigations[:organisation].add_subnavigation("add member", "/organisation/add/member")
    self.navigations[:organisation].add_subnavigation("edit organisation", "/account/edit/organisation/profile")
    self.navigations[:organisation].subnavigation.select(1)

    self.navigations[:organisation].select(2)
    self.navigations[:organisation].add_subnavigation("users", "/users/all")
    self.navigations[:organisation].add_subnavigation("organisations", "/organisations/all")
    self.navigations[:organisation].subnavigation.select(1)

    self.navigations[:organisation].select(3)
    self.navigations[:organisation].add_subnavigation("on sale", "/items/active")
    self.navigations[:organisation].add_subnavigation("create item", "/item/create")
    self.navigations[:organisation].subnavigation.select(1)

    self.navigations[:organisation].select(1)

    self
  end

  def select(name_of_navigation)
    self.selected = self.navigations[name_of_navigation]
  end

  def get
    self.navigations
  end

  def get_selected
    self.selected
  end

  def user
    self.navigations[:user]
  end

  def unregistered
    self.navigations[:unregistered]
  end
end
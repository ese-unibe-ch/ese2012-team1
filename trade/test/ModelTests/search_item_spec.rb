require "test_require"

describe "SearchItem" do
  before(:each) do
    @to_be_searched = double("Searched Item")
    @search_item = SearchItem.create(@to_be_searched, "SearchItem", [:method1, :method2, :method3])
    @system = double("system")
    DAOAccount.stub(:instance).and_return(@system)
    DAOItem.stub(:instance).and_return(@system)
    @system.stub(:account_exists?).and_return(true)
  end

  it "should return priority in the order they are passed" do
    @search_item.priority_of_method(:method1).should == 1
    @search_item.priority_of_method(:method2).should == 2
    @search_item.priority_of_method(:method3).should == 3

    lambda{@search_item.priority_of_method(:method4)}.should raise_error(RuntimeError)
  end

  it "should return priority 1 if user is part of SearchItem" do
    user = double("user")
    user.stub(:id).and_return(1)

    #Stub of class in test because this is a part that has to be implemented in child
    @search_item.should_receive(:part_of?).with(user.id).and_return(true)

    @search_item.priority_of_user(user.id).should == 1
  end

  it "should return priority 2 if user is not part of SearchItem" do
    user = double("user")
    user.stub(:id).and_return(1)

    #Stub of class in test because this is a part that has to be implemented in child
    @search_item.should_receive(:part_of?).with(user.id).and_return(false)

    @search_item.priority_of_user(user.id).should == 2
  end

  context "SearchItem for Item" do
    context "when user is owner" do
      it "#part_of? should return true" do
        item = double("item")
        owner = double("owner")
        item.should_receive(:owner).and_return(owner)
        owner.should_receive(:id).and_return(1)

        search_item = SearchItemItem.create(item, "item", [:callMe])
        search_item.part_of?(1).should == true
      end
    end

    context "when user is not owner" do
      it "#part_of? should return false" do
        item = double("item")
        owner = double("owner")
        item.should_receive(:owner).and_return(owner)
        owner.should_receive(:id).and_return(2)

        search_item = SearchItemItem.create(item, "item", [:callMe])
        search_item.part_of?(1).should == false
      end
    end
  end

  context "SearchItem for User" do
    context "when it is user" do
      it "#part_of? should return true" do
        user = double("user")
        user.should_receive(:id).and_return(1)

        search_item = SearchItemUser.create(user, "user", [:callMe])
        search_item.part_of?(1).should == true
      end
    end

    context "when it is not user" do
      it "#part_of? should return false" do
        user1 = double("user1")
        user2 = double("user2")
        user1.should_receive(:id).and_return(1)
        user2.should_receive(:id).and_return(2)

        search_item = SearchItemUser.create(user1, "user", [:callMe])
        search_item.part_of?(user2.id).should == false
      end
    end
  end

  context "SearchItem for Organisaton" do
    context "when user is member of organisation" do
      it "#part_of? should return true" do
        organisation = double("organisation")
        user = double("user")
        system = double("system")
        DAOAccount.stub(:instance).and_return(system)

        user.stub(:id).and_return(1)
        system.should_receive(:fetch_account).with(user.id).and_return(user)
        organisation.should_receive(:is_member?).with(user).and_return(true)

        search_item = SearchItemOrganisation.create(organisation, "organisation", [:callMe])

        search_item.part_of?(user.id).should == true
      end
    end

    context "when user it no member of organisation" do
      it "#part_of? should return false" do
        organisation = double("organisation")
        user1 = double("user1")
        user2 = double("user2")
        system = double("system")
        DAOAccount.stub(:instance).and_return(system)

        user1.stub(:id).and_return(1)
        system.should_receive(:fetch_account).with(user1.id).and_return(user1)
        organisation.should_receive(:is_member?).with(user1).and_return(false)

        search_item = SearchItemOrganisation.create(organisation, "organisation", [:callMe])
        search_item.part_of?(user1.id).should == false
      end
    end
  end
end
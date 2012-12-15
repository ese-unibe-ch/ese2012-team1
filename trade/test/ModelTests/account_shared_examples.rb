require 'rubygems'
require 'require_relative'
require_relative 'test_require'

def loaded?
  true
end

shared_examples_for "any Account while creation" do
  before(:each) do
    @system = double('system')
    DAOAccount.stub(:instance).and_return(@system)
    DAOItem.stub(:instance).and_return(@system)
    @system.stub(:add_account)
    @system.stub(:email_exists?).and_return(false)

    @search = double('search')
    @search.stub(:register)

    @system.stub(:search).and_return(@search)
  end

  it "should add himself to list in system" do
    @system.should_receive(:add_account)
    create_account
  end
end

shared_examples_for "any created Account" do
    before(:each) do
      @system = double('system')
      DAOAccount.stub(:instance).and_return(@system)
      DAOItem.stub(:instance).and_return(@system)
    end

    it "should have name" do
      @user.name.should be_like  "Bart"
    end

    it "should have description" do
      @user.description.should be_like "I'm Bart"
    end

    it "should have avatar path" do
      @user.avatar.should be_like "/images/users/default_avatar.png"
    end

    it "should not have an id" do
      @user.id.should be_like nil
    end

    it "should have 100 credits" do
      @user.credits.should be_like 100
    end
end


shared_examples_for "any Account buying things" do
  before(:each) do
    @seller = double('seller')
    @seller.stub(:credits).and_return(0)
    @seller.stub(:credits=)

    @item = double('item')
    @item.stub(:owner).and_return(@seller)
    @item.stub(:id).and_return(1)
    @item.stub(:bought_by)
    @system.stub(:items).and_return([1])
  end

  it "should buy it when price is lower than credits and subtract price" do
    @item.stub(:price).and_return(50)
    @user.buy_item(@item)
    @user.credits.should be_like 50
  end

  it "should buy it when price is equal to credits and set credits to 0" do
    @item.stub(:price).and_return(100)
    @user.buy_item(@item)
    @user.credits.should be_like 0
  end

  it "should raise exception when price is higher than credits and leave credits the same" do
    @item.stub(:price).and_return(150)
    lambda { @user.buy_item(@item) }.should raise_error
    @user.credits.should be_like 100
  end
end

shared_examples_for "any Account while item creation" do
  before(:each) do
    @system = double('system')
    DAOAccount.stub(:instance).and_return(@system)
    DAOItem.stub(:instance).and_return(@system)

    @item = double('item')
  end

  def create_item
    @user.create_item('Skateboard', 100)
  end

  it "should create item" do
    Item.should_receive(:created).with('Skateboard', 100, @user)
    @system.stub(:add_item)
    create_item
  end

  it "should add item to the system"  do
    Item.stub(:created).and_return(@item)
    @system.should_receive(:add_item).with(@item)
    create_item
  end

  it "should return item" do
    Item.stub(:created).and_return(@item)
    @system.stub(:add_item)
    received_item = create_item
    received_item.should be @item
  end
end

shared_examples_for "any Account after item creation" do
  before(:each) do
    @system = double('system')
    DAOAccount.stub(:instance).and_return(@system)
    DAOItem.stub(:instance).and_return(@system)

    @item = double('item')
  end

  it "should posses item" do
    @system.stub(:item_exists?).and_return(true)
    @system.stub(:fetch_item).and_return(@item)
    @item.stub(:owner).and_return(@user)
    @user.should have_item(1)
  end

  it "should return his item" do
    @system.stub(:item_exists?).and_return(true)
    @system.stub(:fetch_item).and_return(@item)
    @item.stub(:owner).and_return(@user)

    @user.get_item(1).should be @item
  end

  context "when listing items" do
    it "should return item when item active" do
      @system.stub(:fetch_items_of).and_return([@item])
      @item.stub(:is_active?).and_return(true)
      @user.list_items.should include(@item)
    end

    it "should return item when item inactive" do
      @system.stub(:fetch_items_of).and_return([@item])
      @item.stub(:is_active?).and_return(false)
      @user.list_items.should include(@item)
    end
  end

  context "when listing active items" do
    it "should return item when item active" do
      @system.stub(:fetch_items_of).and_return([@item])
      @item.stub(:is_active?).and_return(true)
      @user.list_active_items.should include(@item)
    end

    it "should not return item when item inactive" do
      @system.stub(:fetch_items_of).and_return([@item])
      @item.stub(:is_active?).and_return(false)
      @user.list_active_items.should_not include(@item)
    end
  end

  context "when listing inactive items" do
    it "should not return item when item active" do
      @system.stub(:fetch_items_of).and_return([@item])
      @item.stub(:is_active?).and_return(true)
      @user.list_inactive_items.should_not include(@item)
    end

    it "should not return item when item inactive" do
      @system.stub(:fetch_items_of).and_return([@item])
      @item.stub(:is_active?).and_return(false)
      @user.list_inactive_items.should include(@item)
    end
  end
end
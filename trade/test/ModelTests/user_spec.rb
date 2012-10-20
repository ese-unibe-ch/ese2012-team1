require "rspec"

require "rubygems"
require "require_relative"

require_relative "../../app/models/user"
require_relative "../../app/models/item"
require_relative "../../app/models/system"
require_relative "../../app/models/organisation"

include Models

class BeLike
  def initialize(comperer)
    @comperer = comperer
  end

  def matches?(to_match)
    to_match == @comperer
  end

  def failure_message_for_should
    "expected to be like \'#{@comperer}\'"
  end
end

class RespondTo
  def initialize(symbol)
    @symbol = symbol
  end

  def matches?(to_match)
    to_match.respond_to?(@symbol)
  end

  def failure_message_for_should
    "expected to respond to @symbol"
  end
end

def be_like(expression)
  BeLike.new(expression)
end

def respond_to(symbol)
  RespondTo.new(symbol)
end

describe "Coupling to" do
  context "System" do
    it "should respond to instance" do
      System.respond_to?(:instance).should be_true
    end

    context "instance" do
      it "should respond to add_account" do
        System.instance.respond_to?(:add_account).should be_true
      end
      it "should respond to add_item" do
        System.instance.respond_to?(:add_item).should be_true
      end
      it "should respond to items" do
        System.instance.should respond_to(:items)
      end
      it "should respond to fetch_items_of" do
        System.instance.respond_to?(:fetch_items_of).should be_true
      end
      it "should respond to remove_account" do
        System.instance.should respond_to(:remove_account)
      end
      it "should respond to fetch_item" do
        System.instance.should respond_to(:fetch_item)
      end
      it "should respond to item_exists?" do
        System.instance.should respond_to(:item_exists?)
      end
      it "should respond to user_exists?" do
        System.instance.should respond_to(:user_exists?)
      end
    end
  end

  context "Item" do
    it "should respond to created" do
      Item.respond_to?(:created).should be_true
    end
    it "should respond to price" do
      Item.new.respond_to?(:price).should be_true
    end
    it "should respond to owner" do
      Item.new.respond_to?(:owner).should be_true
    end
    it "should respond to id" do
      Item.new.respond_to?(:id).should be_true
    end
    it "should respond to bought_by" do
      Item.new.respond_to?(:bought_by).should be_true
    end
    it "should respond to clear" do
      Item.new.should respond_to(:clear)
    end
    it "should respond to is_active?" do
      Item.new.should respond_to(:is_active?)
    end
  end
end

describe "User" do
  before(:each) do
    @system = double('system')
    System.stub(:instance).and_return(@system)
    @system.stub(:add_account)
    @system.stub(:user_exists?).and_return(true)
  end

  def create_user
    User.created("Bart", "password", "bart@mail.ch", "I'm Bart", "/images/users/default_avatar.png")
  end

  context "when created" do
    before(:each) do
      @user = User.created("Bart", "password", "bart@mail.ch", "I'm Bart", "/images/users/default_avatar.png")
    end

    it "should have name" do
      @user.name.should be_like  "Bart"
    end

    it "should have email" do
      @user.email.should be_like "bart@mail.ch"
    end

    it "should have description" do
      @user.description.should be_like "I'm Bart"
    end

    it "should have avatar path" do
      @user.avatar.should be_like "/images/users/default_avatar.png"
    end

    it "should have 100 credits" do
      @user.credits.should be_like 100
    end

    it "should have encrypted password" do
      @user.password_hash.should_not be_like nil
      @user.password_salt.should_not be_like nil
      @user.password_hash.should_not be_like "password"
      @user.password_salt.should_not be_like "password"
    end

    it "should not have an id" do
      @user.id.should be_like nil
    end

    it "should not have any member" do
      #This is not really a good test...
      @user.is_member?(nil).should be_false
    end

    it "should add himself to list in system" do
      @system.should_receive(:add_account)
      User.created("Bart", "password", "bart@mail.ch", "I'm Bart", "/images/users/default_avatar.png")
    end

    context "when logging in" do
      it "should return false when password is wrong" do
        @user.login("passwor").should be_false
      end
      it "should return true when password is correct" do
        @user.login("password").should be_true
      end
    end
  end

  context "when creating an organisation" do
    before(:each) do
      @user = create_user
      @organisation = double('organisation')
      @organisation.stub(:organisation=)
      # I would rather have that the creator of an organisation is automatically a member
      @organisation.should_receive(:add_member).with(@user)
      Organisation.stub(:created).and_return(@organisation)
    end

    it "should create an organisation" do
      Organisation.should_receive(:created).with("org", "I'm organisation", "/images/organisations/default_avatar.png")
      @user.create_organisation("org", "I'm organisation", "/images/organisations/default_avatar.png")
    end
  end


  context "when buy things" do
    before(:each) do
      @user = User.created("Bart", "password", "bart@mail.ch", "I'm Bart", "/images/users/default_avatar.png")
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

  context "while item creation" do
    before(:each) do
      @user = User.created("Bart", "password", "bart@mail.ch", "I'm Bart", "/images/users/default_avatar.png")
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

  context "after item creation" do
    before(:each) do
      @user = User.created("Bart", "password", "bart@mail.ch", "I'm Bart", "/images/users/default_avatar.png")
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

  context "#clear" do
    before(:each) do
      @user = create_user
    end

    it "should remove user from system" do
      @system.stub(:fetch_items_of).and_return([])
      @user.stub(:id).and_return(1)
      @system.should_receive(:remove_account).with(1)
      @user.clear
    end

    context "with one item" do
      it "should clear one item" do
        @item = double('item')
        @system.stub(:fetch_items_of).and_return([@item])
        @system.stub(:remove_account)
        @item.should_receive(:clear)
        @user.clear
      end
    end

    context "with three items" do
      it "should clear three items" do
        @item = double('item')
        @system.stub(:fetch_items_of).and_return([@item, @item, @item])
        @system.stub(:remove_account)
        @item.should_receive(:clear).exactly(3).times
        @user.clear
      end
    end
  end
end
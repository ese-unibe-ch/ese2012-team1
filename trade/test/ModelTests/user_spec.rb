require 'test_require'

describe "Coupling to" do
  context "DAOAccount" do
    it "should respond to instance" do
      DAOAccount.respond_to?(:instance).should be_true
    end

    context "instance" do
      it "should respond to add_account" do
        DAOAccount.instance.respond_to?(:add_account).should be_true
      end
      it "should respond to remove_account" do
        DAOAccount.instance.should respond_to(:remove_account)
      end
      it "should respond to email_exists?" do
        DAOAccount.instance.should respond_to(:email_exists?)
      end
    end

    context "DAOItem" do
      it "should respond to instance" do
        DAOItem.respond_to?(:instance).should be_true
      end

      context "instance" do
        it "should respond to add_item" do
          DAOItem.instance.respond_to?(:add_item).should be_true
        end
        it "should respond to fetch_items_of" do
          DAOItem.instance.respond_to?(:fetch_items_of).should be_true
        end
        it "should respond to fetch_item" do
          DAOItem.instance.should respond_to(:fetch_item)
        end
        it "should respond to item_exists?" do
          DAOItem.instance.should respond_to(:item_exists?)
        end
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
    DAOItem.stub(:instance).and_return(@system)
    DAOAccount.stub(:instance).and_return(@system)
    @system.stub(:add_account)
    @system.stub(:email_exists?).and_return(false)

    @search = double('search')
    @search.stub(:register)

    @system.stub(:search).and_return(@search)
  end

  def create_account
    User.created("Bart", "password", "bart@mail.ch", "I'm Bart", "/images/users/default_avatar.png")
  end

  context "while creation" do
    it_behaves_like "any Account while creation"
  end

  context "when created" do
    before(:each) do
      @user = create_account
    end

    it_behaves_like "any created Account"

    it "should have email" do
      @user.email.should be_like "bart@mail.ch"
    end

    it "should have encrypted password" do
      @user.password_hash.should_not be_like nil
      @user.password_salt.should_not be_like nil
      @user.password_hash.should_not be_like "password"
      @user.password_salt.should_not be_like "password"
    end

    it "should not have any member" do
      #This is not really a good test...
      @user.is_member?(nil).should be_false
    end

    context "when logging in" do
      it "should return false when password is wrong" do
        @user.login("passwor").should be_false
      end
      it "should return true when password is correct" do
        @user.login("password").should be_true
      end
    end

    it_behaves_like "any Account while item creation"
    it_behaves_like "any Account after item creation"

    context "when creating an organisation" do
      before(:each) do
        @user = create_account
        @organisation = double('organisation')
        @organisation.stub(:organisation=)
        # I would rather have that the creator of an organisation is automatically a member
        @organisation.should_receive(:add_member).with(@user)
        Organisation.stub(:created).and_return(@organisation)
        @organisation.stub(:set_as_admin)
      end

      it "should create an organisation" do
        Organisation.should_receive(:created).with("org", "I'm organisation", "/images/organisations/default_avatar.png")
        @user.create_organisation("org", "I'm organisation", "/images/organisations/default_avatar.png")
      end

      it "should be admin" do
        @organisation.should_receive(:set_as_admin).with(@user)
        @user.create_organisation("org", "I'm organisation", "/images/organisations/default_avatar.png")
      end

    end

    context "#clear" do
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
end
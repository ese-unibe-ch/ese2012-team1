require "rubygems"
require "rspec"
require "require_relative"

require_relative "../../app/models/organisation"

#should not load a second time if already loaded
require_relative "account_shared_examples"

include Models

describe "Organisation" do
  before(:each) do
    @system = double('system')
    System.stub(:instance).and_return(@system)
    @system.stub(:add_account)
    @system.stub(:user_exists?).and_return(false)
  end

  def create_account
    Organisation.created("Bart", "I'm Bart", "/images/users/default_avatar.png")
  end

  context "while creation" do
    it_behaves_like "any Account while creation"
  end

  context "when created" do
    before(:each) do
      @user = create_account
    end

    it_behaves_like "any created Account"

    it "should have user sink" do
      @user.respond_to?(:users)
    end

    it "should not have any member" do
      @user.users.empty?.should be_true
    end

    it_behaves_like "any Account while item creation"
    it_behaves_like "any Account after item creation"

    context "adding and removing members" do
      before(:each) do
        @user_to_be_member = double('member')
        @user_to_be_member.stub(:email).and_return("bart@mail.ch")
      end

      it "should not be member when not added" do
        @user.is_member?(@user_to_be_member).should be_false
      end

      it "should be member when added" do
        @user.add_member(@user_to_be_member)
        @user.is_member?(@user_to_be_member).should be_true
      end

      it "should not be member when removed" do
        @user.add_member(@user_to_be_member)
        @user.is_member?(@user_to_be_member)
        @user.remove_member(@user_to_be_member)
      end

      it "multiple add users add should be member" do
        @member1 = double('member1')
        @member2 = double('member2')
        @member3 = double('member3')

        @member1.stub(:email).and_return("bart@mail.ch")
        @member2.stub(:email).and_return("homer@mail.ch")
        @member3.stub(:email).and_return("maggie@mail.ch")

        @user.add_member(@member1)
        @user.add_member(@member2)
        @user.add_member(@member3)

        @user.is_member?(@member1).should be_true
        @user.is_member?(@member2).should be_true
        @user.is_member?(@member3).should be_true
      end
    end


    context "#clear" do
      it "should remove organisation from system" do
        pending()
        @system.stub(:fetch_items_of).and_return([])
        @user.stub(:id).and_return(1)
        @system.should_receive(:remove_account).with(1)
        @user.clear
      end

      context "with one item" do
        it "should clear one item" do
          pending()
          @item = double('item')
          @system.stub(:fetch_items_of).and_return([@item])
          @system.stub(:remove_account)
          @item.should_receive(:clear)
          @user.clear
        end
      end

      context "with three items" do
        it "should clear three items" do
          pending()
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
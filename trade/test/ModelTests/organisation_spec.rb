require 'test_require'

require_relative "account_shared_examples"

describe "Organisation" do
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

    it "should have user sink" do  # @pas what does this mean?? is not a sink, where you wash your dishes? xD
      @user.respond_to?(:members)
    end

    it "should not have any member" do
      @user.members.empty?.should be_true
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
        @admin1 = double('member1')
        @member2 = double('member2')
        @member3 = double('member3')

        @admin1.stub(:email).and_return("bart@mail.ch")
        @member2.stub(:email).and_return("homer@mail.ch")
        @member3.stub(:email).and_return("maggie@mail.ch")

        @user.add_member(@admin1)
        @user.add_member(@member2)
        @user.add_member(@member3)

        @user.is_member?(@admin1).should be_true
        @user.is_member?(@member2).should be_true
        @user.is_member?(@member3).should be_true
      end
    end

    context "adding and removing admin rights" do
      before(:each) do
        @member_to_be_admin = double('member_to_be_admin')
        @member_to_be_admin.stub(:email).and_return("bart@mail.ch")
        @organisation = create_account
      end

      it "creator should have admin right" do
        # It's not a good test, but I dont know how I should imitate
        # the situation, that the creator should automatically have
        # admin rights. This would have to be in user, right?
        # But there is already a such a test.
        @organisation.set_as_admin(@member_to_be_admin)
        @organisation.is_admin?(@member_to_be_admin).should be_true
      end

      it "should not revoke admin right if only one admin" do
        @organisation.set_as_admin(@member_to_be_admin).should raise_error
      end

      it "should revoke admin rights" do
        # Cannot remove admin rights, if only one admin is left ;)
        @member_to_be_admin2 = double('member_to_be_admin2')
        @member_to_be_admin2.stub(:email).and_return("lisa@mail.ch")

        @organisation.set_as_admin(@member_to_be_admin)
        @organisation.set_as_admin(@member_to_be_admin2)

        @organisation.revoke_admin_rights(@member_to_be_admin)
        @organisation.is_admin?(@member_to_be_admin).should_not be_true
      end

      it "should count number of admins" do
        @admin1 = double('admin1')
        @admin2 = double('admin2')
        @admin3 = double('admin3')

        @admin1.stub(:email).and_return("bart@mail.ch")
        @admin2.stub(:email).and_return("homer@mail.ch")
        @admin3.stub(:email).and_return("maggie@mail.ch")

        @user.add_member(@admin1)
        @user.add_member(@admin2)
        @user.add_member(@admin3)

        @user.admin_count.should eq(0)

        @user.set_as_admin(@admin1)
        @user.set_as_admin(@admin2)
        @user.set_as_admin(@admin3)

        @user.admin_count.should eq(3)
        @user.revoke_admin_rights(@admin3)

        @user.admin_count.should eq(2)
        @user.revoke_admin_rights(@admin2)
        @user.admin_count.should eq(1)
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
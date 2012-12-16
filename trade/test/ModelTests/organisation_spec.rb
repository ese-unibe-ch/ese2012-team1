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
      @organisation = @user
    end

    it_behaves_like "any created Account"

    it "should have list of members" do
      @user.respond_to?(:members)
    end

    it "should not have any member" do
      @user.members.empty?.should be_true
    end

    it_behaves_like "any Account while item creation"
    it_behaves_like "any Account after item creation"

    context "when user limit is set" do
      before(:each) do
        @normal_user = double("Normal User")
        @normal_user.stub(:email).and_return("normal@mail.ch")
        @admin = double("Admin")
        @admin.stub(:email).and_return("admin@mail.ch")

        @organisation.add_member(@normal_user)
        @organisation.add_member(@admin)
        @organisation.set_as_admin(@admin)
        @organisation.set_limit(50)
      end

      it "normal user should have same limit" do
        @organisation.get_limit(@normal_user).should == 50
      end

      it "admins should have not limit" do
        @organisation.get_limit(@admin).should == nil
      end
    end

    context "when buying items" do
      before(:each) do
        @seller = double("Seller")
        @seller.stub(:credits).and_return(100)
        @seller.stub(:credits=)

        @buyer = double("Buyer")
        @buyer.stub(:organisation).and_return(false)
        @buyer.stub(:email).and_return("buyer@mail.ch")
        @organisation.add_member(@buyer)

        @item = double("Item")
        @item.stub(:price).and_return(20)
        @item.stub(:id).and_return(0)
        @item.stub(:owner).and_return(@seller)
        @item.stub(:bought_by)

        @system.stub(:item_exists?).and_return(true)
      end

      it "should add credits to seller" do
        @seller.should_receive(:credits=).with(@seller.credits + @item.price)

        @organisation.buy_item(@item, @buyer)
      end

      it "should set organisation as buyer" do
        @item.should_receive(:bought_by).with(@organisation)

        @organisation.buy_item(@item, @buyer)
      end

      it "should not sell item when buy is on behalf of an organisation" do
        @buyer.should_receive(:organisation).and_return(true)

        lambda{ @organisation.buy_item(@item, @buyer) }.should raise_error(RuntimeError)
      end

      it "should not sell item if user is not part of organisation" do
        @organisation.remove_member(@buyer)

        lambda{ @organisation.buy_item(@item, @buyer) }.should raise_error(RuntimeError)
      end


      it "should not sell item if organisation has not enough credits" do
        @organisation.credits = @item.price - 10

        lambda { @organisation.buy_item(@item, @buyer) }.should raise_error(RuntimeError)
      end

      context "when user limit set" do
        before(:each) do
          @organisation.set_limit(50)
        end

        it "user should buy over limit when admin" do
          @organisation.set_as_admin(@buyer)
          @item.stub(:price).and_return(60)

          @organisation.buy_item(@item, @buyer)
        end

        it "user should not buy over limit when not admin" do
          @item.stub(:price).and_return(60)

          lambda{@organisation.buy_item(@item, @buyer)}.should raise_error(RuntimeError)
        end

        it "user should buy item within limit" do
          @item.stub(:price).and_return(20)
          @item.should_receive(:bought_by).with(@organisation)

          @organisation.buy_item(@item, @buyer)
        end

        it "user should have limit decreased by cost" do
          @item.stub(:price).and_return(20)

          @organisation.buy_item(@item, @buyer)

          @organisation.get_limit(@buyer).should == 30
        end

        context "when bought item and limit changes" do
          before(:each) do
            @item.stub(:price).and_return(20)
            @organisation.buy_item(@item, @buyer)
          end

          it "remaining limit should be calculated on base of the spend money" do
            @organisation.set_limit(70)
            @organisation.get_limit(@buyer).should == 50
          end

          it "remaining limit should be zero if limit is smaller than amount spend" do
            @organisation.set_limit(10)
            @organisation.get_limit(@buyer).should == 0
          end

          it "when reset limit then limit should be as before" do
            @organisation.reset_member_limits
            @organisation.get_limit(@buyer).should == 50
          end

          context "to nil" do
            it "user should buy items without limit" do
              @item.stub(:price).and_return(80)
              @organisation.set_limit(nil)
              @item.should_receive(:bought_by).with(@organisation)

              @organisation.buy_item(@item, @buyer)
            end
          end
        end
      end
    end

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

        @member_to_be_admin2 = double('member_to_be_admin2')
        @member_to_be_admin2.stub(:email).and_return("lisa@mail.ch")

        @organisation = create_account
      end

      it "should not revoke admin right if only one admin" do
        @organisation.add_member(@member_to_be_admin)
        @organisation.set_as_admin(@member_to_be_admin)
        lambda{@organisation.revoke_admin_rights(@member_to_be_admin)}.should raise_error(RuntimeError)
      end

      it "should be last admin when only on user is admin" do
        @organisation.add_member(@member_to_be_admin)
        @organisation.set_as_admin(@member_to_be_admin)
        @organisation.is_last_admin?(@member_to_be_admin).should be_true
      end

      it "should not be last admin when two users ar set as admin" do
        @organisation.add_member(@member_to_be_admin)
        @organisation.add_member(@member_to_be_admin2)

        @organisation.set_as_admin(@member_to_be_admin)
        @organisation.set_as_admin(@member_to_be_admin2)

        @organisation.is_last_admin?(@member_to_be_admin).should be_false
        @organisation.is_last_admin?(@member_to_be_admin2).should be_false;
      end

      it "should revoke admin rights" do
        @organisation.add_member(@member_to_be_admin)
        @organisation.add_member(@member_to_be_admin2)
        # Cannot remove admin rights, if only one admin is left ;)
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
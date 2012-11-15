require "rspec"
require 'rubygems'

require 'require_relative'
require_relative('../../app/models/item')
require_relative('../../app/models/system')
require_relative('../../app/models/account')

require_relative('custom_matchers')

include CustomMatchers
include Models

##
#
# Checks if objects provide the interface
# used in Item.
#
# If those tests fail the interface for objects
# used by Item (not Item itself)
# has changed.
#
##

describe "Coupling for Item:" do
  context "System" do
    before(:each) do
      @system = System.instance
    end

    it "should response to instance" do
      System.should respond_to(:instance)
    end

    it "should respond to remove" do
      @system.should respond_to(:remove_item)
    end
  end

  context "Account" do
    before(:each) do
      @account = Account.created("Bart", "Ay, caramba!", "/images/users/default_avatar.png")
    end

    it "should response to credits" do
      @account.should respond_to(:credits)
    end
  end
end

##
#
# Tests Item without any real coupling to
# other objects.
#
##

describe Models::Item do
  def create_item
    @owner = double('Owner')
    Models::Item.created("testobject", 50, @owner)
  end

  context "after creation" do
    before(:each) do
      @item = create_item
    end

    it "should have name" do
      @item.name.should be_like "testobject"
    end

    it "should have price" do
      @item.price.should be_like 50
    end

    it "should not be active" do
      @item.is_active?.should be_false
    end

    it "should have no item id (nil)" do
      @item.id.should be_nil
    end

    it "should have an empty description" do
      @item.description.show.should be_like ""
    end

    context "when added a description" do
      before(:each) do
        @item.add_description("very valuable")
      end

      it "should have a description" do
        @item.description.show.should be_like "very valuable"
      end
    end

    context "when an item path added" do
      before(:each) do
        @item.add_picture("/images/items/default_item.png")
      end

      it "should have path to file stored" do
        @item.picture.should be_like "/images/items/default_item.png"
      end
    end

    context "when inactive" do
      before(:each) do
        @item.to_inactive
      end

      it "should not be editable" do
        @item.should_not be_editable
      end

      it "should not be bought by user with to few money" do
        @owner.stub(:credits).and_return(20)
        @item.can_be_bought_by?(@owner).should be_false
      end

      it "should not be bought by user with enough money" do
        @owner.stub(:credits).and_return(50)
        @item.can_be_bought_by?(@owner).should be_false
      end
    end

    context "when set to active" do
      before(:each) do
        @item.to_active
      end

      it "should be active" do
        @item.is_active?.should be_true
      end

      it "should be set to inactive when used to_inactive" do
        @item.to_inactive
        @item.is_active?.should be_false
      end

      it "should be editable" do
        @item.should be_editable
      end

      it "should not be bought by user with to few money" do
        @owner.stub(:credits).and_return(20)
        @item.can_be_bought_by?(@owner).should be_false
      end

      it "should be bought by user with enough money" do
        @owner.stub(:credits).and_return(50)
        @item.can_be_bought_by?(@owner).should be_true
      end
    end

    context "#clear" do
      before(:each) do
        @system = double('System')
        System.stub(:instance).and_return(@system)
        @system.stub(:remove_item)
        @item.id = 1
      end

      context "when set custom picture" do
        it "should remove picture from file system" do
          #This mock on the tested items is so that i don't have to create a real item
          #because the add_picture() methods checks for that.
          @item.stub(:picture).and_return("../../app/public/images/items/test.png")

          File.should_receive(:delete).once
          @item.clear
        end
      end

      it "should not remove picture from file system" do
        File.should_not_receive(:delete)
        @item.clear
      end

      it "should remove item from system" do
        @system.should_receive(:remove_item).with(@item.id)
        @item.clear
      end
    end

    context "when bought" do
      before(:each) do
        @new_owner = double("new owner")
        @item.bought_by(@new_owner)
      end

      it "should set new owner as owner" do
        @item.owner.should equal @new_owner
      end

      context "and was active before" do
        it "should be inactive" do
          @item.is_active?.should be_false
        end
      end
    end
  end
end
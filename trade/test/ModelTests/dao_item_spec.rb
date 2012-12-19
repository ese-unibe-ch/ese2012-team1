require "test_require"

describe DAOItem do
  before(:each) do
    @items = Models::DAOItem.instance

    @accounts = double("Accounts")
    DAOAccount.stub(:instance).and_return(@accounts)

    @users = { :kassiopeia => double("Kassiopeia"),
               :momo => double("Momo"),
               :beppo => double("Beppo") }

    @users[:momo].stub(:id).and_return(0)
    @users[:beppo].stub(:id).and_return(1)
    @users[:kassiopeia].stub(:id).and_return(2)

    @items.reset
  end

  def double_item(name, id, owner)
    item = double(name)
    item.should_receive(:id).and_return(nil)
    item.should_receive(:id=).with(id)
    item.stub(:id).and_return(id)
    item.stub(:owner).and_return(owner)

    item
  end

  def add_items
    @some_items = { :curly_hair => double_item("Curly Hair", 0, @users[:momo]),
                    :sand => double_item("Hourflower", 1, @users[:momo]),
                    :broom => double_item("Broom", 2, @users[:beppo]),
                    :time => double_item("Time", 3, @users[:kassiopeia]) }

    @items.add_item(@some_items[:curly_hair])
    @items.add_item(@some_items[:sand])
    @items.add_item(@some_items[:broom])
    @items.add_item(@some_items[:time])
  end

  context "when created" do
    it "should add an item" do
      @items.count_items.should == 0

      friends = double_item("friends", 0, "Momo")

      @items.add_item(friends)
      @items.count_items.should == 1

      stories = double_item("stories", 1, "Beppo")
      @items.add_item(stories)
      @items.count_items.should == 2

      clocks = double_item("clocks", 2, "Meister Hora")
      @items.add_item(clocks)
      @items.count_items.should == 3
    end

    context "when items where added" do
      before(:each) do
        add_items
      end

      it "should fetch item" do
        fetched_item = @items.fetch_item(@some_items[:time].id)
        fetched_item.should == @some_items[:time]
      end

      it "should fetch item of user" do
        @accounts.should_receive(:account_exists?).with(2).and_return(true)
        items_cassiopeia = @items.fetch_items_of(@users[:kassiopeia].id)

        @accounts.should_receive(:account_exists?).with(0).and_return(true)
        items_momo = @items.fetch_items_of(@users[:momo].id)

        items_cassiopeia.size.should == 1
        items_cassiopeia.include?(@some_items[:time]).should be_true

        items_momo.size.should == 2
        items_momo.include?(@some_items[:sand]).should be_true
        items_momo.include?(@some_items[:curly_hair]).should be_true
      end

      it "should_fetch_all_items_but_of_user" do
        @accounts.should_receive(:account_exists?).with(0).and_return(true)

        remaining = @items.fetch_all_items_but_of(@users[:momo].id)
        remaining.include?(@some_items[:broom]).should be_true
        remaining.include?(@some_items[:time]).should be_true
        remaining.size.should == 2
      end

      it "should_remove_added items" do
        @items.count_items.should == 4

        @items.remove_item(@some_items[:broom].id)
        @items.item_exists?(@some_items[:broom].id).should be_false
        @items.count_items.should == 3

        @items.remove_item(@some_items[:sand].id)
        @items.remove_item(@some_items[:curly_hair].id)
        @items.remove_item(@some_items[:time].id)

        @items.count_items.should == 0
      end

      context "when fetching active items" do
        before(:each) do
          @accounts.stub(:account_exists?).and_return(true)
        end

        it "should return item when item active" do
          @some_items[:broom].stub(:is_active?).and_return(true)
          @items.fetch_active_items_of(@users[:beppo].id).should include(@some_items[:broom])
        end

        it "should not return item when item inactive" do
          @some_items[:broom].stub(:is_active?).and_return(false)
          @items.fetch_active_items_of(@users[:beppo].id).should_not include(@some_items[:broom])
        end
      end

      context "when listing inactive items" do
        before(:each) do
          @accounts.stub(:account_exists?).and_return(true)
        end

        it "should not return item when item active" do
          @some_items[:broom].stub(:is_active?).and_return(true)
          @items.fetch_inactive_items_of(@users[:beppo].id).should_not include(@some_items[:broom])
        end

        it "should not return item when item inactive" do
          @some_items[:broom].stub(:is_active?).and_return(false)
          @items.fetch_inactive_items_of(@users[:beppo].id).should include(@some_items[:broom])
        end
      end
    end
  end
end
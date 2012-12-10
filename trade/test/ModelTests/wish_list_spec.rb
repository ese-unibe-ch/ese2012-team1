require 'test_require'

describe WishList do
  def create_wish_list
    w = WishList.new
  end

  context "while creation" do

    it "should have array for items" do
      @wish_list = create_wish_list
      @wish_list.items.should {}
    end

  end

  context "adding & removing items" do

    before(:each) do
      @item = double('item')
      @item.stub(:id).and_return(1)
      @item.stub(:is_active?).and_return(true)
      @wish_list = create_wish_list
    end

    it "should add item" do
      @item.should_receive(:add_observer).with(@wish_list)
      @wish_list.add(@item)
      @wish_list.items[0].should == @item
    end

    it "should remove item" do
      @item.should_receive(:add_observer).with(@wish_list)
      @wish_list.add(@item)

      @item.should_receive(:remove_observer).with(@wish_list)
      @wish_list.remove(@item)
      @wish_list.items.empty? == true
    end
  end

  context "updating items" do
    before(:each) do
      @item = double('item')
      @item.stub(:id).and_return(1)
      @item.stub(:is_active?).and_return(true)
      @wish_list = create_wish_list
      @item.should_receive(:add_observer).with(@wish_list)
      @wish_list.add(@item)
    end

    it "should stay the same if stays active" do
      @item.should_receive(:remove_observer).with(@wish_list)

      @wish_list.update(@item)
      @wish_list.items[0] == @item
    end

    it "should remove item if inactive" do
      @item.should_receive(:remove_observer).with(@wish_list)

      @item.stub(:is_active?).and_return(false)
      @wish_list.update(@item)
      @wish_list.items.empty? == true
    end
  end
end
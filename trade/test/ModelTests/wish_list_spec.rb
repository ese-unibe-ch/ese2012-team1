require 'test_require'

describe WishList do
  def create_wish_list
    w = WishList.new
  end

  context "while creation" do

    it "should have hash for items" do
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
      Item.should_receive(:to_inactive)
      Item.should_receive(:add_observer).with(@item)
      @wish_list.add(@item)
      @wish_list.items[0].should == @item
    end

  end
end
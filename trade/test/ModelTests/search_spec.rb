require "rubygems"
require "rspec"
require "require_relative"

require "../../app/models/search"
require_relative "custom_matchers"

include CustomMatchers

describe "Search" do
  def create_search
    Search.new
  end

  before(:each) do
    @search = create_search
  end

  it "should be created" do
    @search = Search.new
  end

  it "not have any search items" do
    @search.items.should be_empty
  end

  it "should not find any items" do
    result = @search.find("")
    result.should be_empty
  end

  it "should register items with correct methods" do
    item = double('item')
    @search.register(item, "item", [:method1, :method2])

    item.should_receive(:method1).and_return("test")
    item.should_receive(:method2).and_return("test2")

    @search.find("tset")
  end

  context "with one registered item" do
    before(:each) do
      @item = double('item')
      @search.register(@item, "item", [:method1, :method2])

      @item.stub(:method1).and_return("test1")
      @item.stub(:method2).and_return("test2")
    end

    it "should not have results when searched string is not included in return value" do
       @search.find("3").should be_empty
    end

    it "should return one item when search string is included in return value" do
      @search.find("test").size.should == 1
    end

    it "should return registered item when string ist included in return value" do
      @search.find("test").get("item")[0].should be @item
    end
  end

  context "with multiple registered items" do
    before(:each) do
      @item1 = double('cheese')
      @item2 = double('cake')

      @furniture1 = double('table')
      @furniture2 = double('sofa')

      @drink1 = double('coke')

      @search.register(@item1, "food", [:ingredients])
      @search.register(@item2, "food", [:ingredients])
      @search.register(@furniture1, "furniture", [:color])
      @search.register(@furniture2, "furniture", [:color])
      @search.register(@drink1, "drink", [:size])

      @furniture1.stub(:color).and_return("blue")
      @furniture2.stub(:color).and_return("chocolate brown")
      @item1.stub(:ingredients).and_return("milk, salt, herbes")
      @item2.stub(:ingredients).and_return("egg, flower, chocolate")
      @drink1.stub(:size).and_return("1 liter")
    end

    it "should return all items with an r when search string is \'r\'" do
      result = @search.find("r")

      result.member?("furniture").should be_true
      result.member?("food").should be_true
      result.member?("drink").should be_true

      result.get("furniture").size.should == 1
      result.get("furniture").include?(@furniture1).should be_false
      result.get("furniture").include?(@furniture2).should be_true

      result.get("food").size.should == 2
      result.get("food").include?(@item1).should be_true
      result.get("food").include?(@item2).should be_true

      result.get("drink").size.should == 1
      result.get("drink").include?(@drink1).should be_true
    end

    it "should return all items containing \'brown\' when search string is \'brown\'" do
      result = @search.find("chocolate")

      result.member?("furniture").should be_true
      result.member?("food").should be_true
      result.member?("drink").should be_false

      result.get("furniture").size.should == 1
      result.get("furniture").include?(@furniture1).should be_false
      result.get("furniture").include?(@furniture2).should be_true

      result.get("food").size.should == 1
      result.get("food").include?(@item1).should be_false
      result.get("food").include?(@item2).should be_true
    end
  end
end
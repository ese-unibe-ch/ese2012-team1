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

  it "should register items with method to call" do
    item = double('item')
    @search.register(item, [:method1, :method2])

    item.should_receive(:method1).and_return("test")
    item.should_receive(:method2).and_return("test2")

    @search.find("tset")
  end
end
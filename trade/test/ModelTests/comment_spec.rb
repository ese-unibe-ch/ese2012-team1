require "rubygems"
require "rspec"
require "require_relative"

require "../../app/models/comment"
require_relative "custom_matchers"

include CustomMatchers

describe Comment do
  def create_comment
    @user = double('User')
    Comment.create(@user, "Header", "Hi, I'm a comment!")
  end

  context "while creation" do
    it "should demand creator, header and comment" do
      user = double()
      comment = create_comment
      comment.should_not be_nil
    end
  end

  context "after creation" do
    before(:each) do
      @comment = create_comment
    end

    it "should have unique nr 0" do
      @comment.nr.should_not be_nil
    end

    it "should hold comment" do
      @comment.comment.should be_like "Hi, I'm a comment!"
    end

    it "should have header" do
      @comment.header.should be_like "Header"
    end

    it "should know its creator" do
      @comment.creator.should equal(@user)
    end

    it "should collect one comment" do
      @comment.collect.size.should == 1
    end

    it "should collect himself" do
      @comment.collect[0].should == @comment
    end

    it "should have depth 0" do
      @comment.depth.should == 0
    end

    it "should add comments and set depth to 1" do
      @added_comment = Comment.create(@user, "header", "'m the comment added")
      @comment.add(@added_comment)
      @added_comment.depth = 1
    end

    it "should add comments and set unique nr one bigger" do
      @added_comment = Comment.create(@user, "header", "'m the comment added")
      @comment.add(@added_comment)
      @added_comment.nr.should == @comment.nr+1
    end

    it "should travers himself" do
      meet_self = false
      @comment.travers { |comment| meet_self = true if comment.equal?(@comment) }
      meet_self.should be_true
    end
  end
end
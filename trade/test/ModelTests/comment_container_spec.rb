require "rubygems"

require "rspec"
require "require_relative"

require_relative("../../app/models/comment_container")
require_relative("../../app/models/comment")


##
#
# Checks if objects provide the interface
# used in CommentContainer.
#
# If those tests fail the interface for objects
# used by CommentContainer (not CommentContainer itself)
# has changed.
#
##

describe "Coupling for CommentContainer:" do
  context "Comment" do
    before(:each) do
      user = double('User')
      @comment = Comment.create(user, "header", "Hey there")
    end

    it "should respond to collect" do
      @comment.should respond_to(:collect)
    end

    it "should respond to depth" do
      @comment.should respond_to(:depth)
    end
  end
end

##
#
# Tests CommentContainer without any real coupling to
# other objects.
#
##

describe CommentContainer do
  context "after creation" do
    def create_comment
      comment = double('Comment')
      comment.stub(:depth=)
      comment
    end

    before(:each) do
      @container = CommentContainer.new
    end

    it "should have zero comment" do
      @container.size.should == 0
    end

    it "should travers zero comments" do
      @container.travers { |comment| fail() }
    end

    it "should have depth zero" do
      @container.depth.should == 0
    end

    it "should collect zero comments" do
      @container.collect.size.should == 0
    end

    it "should accept a comment" do
      comment = create_comment
      @container.add(comment)
    end

    context "adding a comment" do
      before(:each) do
        @comment = create_comment
        @container.add(@comment)
        @comment.stub(:collect).and_return([@comment])
        @comment.stub(:depth)
      end

      it "should set depth 1" do
        comment = double('Comment')
        comment.should_receive(:depth=).with(1)
        @container.add(comment)
      end

      it "should have one child" do
        @container.size.should == 1
      end

      it "should collect one comment" do
        @container.collect.size.should == 1
      end

      it "should collect correct comment" do
        @container.collect[0].should == @comment
      end

      it "should meet comment when traversing" do
        meet_comment = false
        @container.travers { |comment| meet_comment = true if comment.equal?(@comment) }
        meet_comment.should be_true
      end
    end

    context "and adding two comments" do
      before(:each) do
        @comment1 = double('First comment')
        @comment1.stub(:depth=)
        @comment2 = double('Second comment')
        @comment2.stub(:depth=)

        @container.add(@comment1)
        @container.add(@comment2)

        @comment1.stub(:collect).and_return([@comment1])
        @comment2.stub(:collect).and_return([@comment2])

        @comment1.stub(:nr).and_return(1)
        @comment2.stub(:nr).and_return(2)
      end

      it "should have two children" do
        @container.size.should == 2
      end

      it "should meet both comments when traversing" do
        meet_comment1 = false
        meet_comment2 = false

        @container.travers  do |comment|
          meet_comment1 = true if comment.equal?(@comment1)
          meet_comment2 = true if comment.equal?(@comment2)
        end

        meet_comment1.should be_true
        meet_comment2.should be_true
      end

      it "should meet comments in order added" do
        meet_comment1 = false
        meet_comment2 = false

        @container.travers  do |comment|
          meet_comment1 = true if comment.equal?(@comment1)
          meet_comment2 = true if comment.equal?(@comment2)&&meet_comment1==true
        end

        meet_comment1.should be_true
        meet_comment2.should be_true
      end

      it "should get comment by nr" do
        @container.get(@comment1.nr).should equal @comment1
        @container.get(@comment2.nr).should equal @comment2
      end
    end

    context "add to a CommentContainer" do
      it "should have depth one" do
        comment_container = CommentContainer.new
        parent_comment_container = CommentContainer.new
        parent_comment_container.add(comment_container)
        comment_container.depth.should == 1
      end

      context "with depth 1" do
        comment_container = CommentContainer.new
        parent_comment_container = CommentContainer.new
        parent_comment_container.depth = 1
        parent_comment_container.add(comment_container)
        comment_container.depth.should == 2
      end
    end

    context "adding a CommentContainer" do
      before(:each) do
        @comment_container = CommentContainer.new
        @container.add(@comment_container)
      end

      it "should have one child" do
        @container.size.should == 1
      end

      it "should not meet CommentContainer when traversing" do
        meet_comment = false
        @container.travers { |comment| meet_comment = true if comment.equal?(@comment_container) }
        meet_comment.should be_false
      end

      context "with holding another comment" do
        before(:each) do
          @comment = create_comment
          @comment.stub(:collect).and_return([@comment])
          @comment_container.add(@comment)
        end

        it "should have one child" do
          @container.size.should == 1
        end

        it "should collect one comment" do
          @container.collect.size.should == 1
        end

        it "should collect correct comment" do
          @container.collect[0].should equal @comment
        end

        it "should meet comment when traversing" do
          meet_comment_container = false
          meet_comment = false

          @container.travers  do |comment|
            meet_comment_container = true if comment.equal?(@comment_container)
            meet_comment = true if comment.equal?(@comment)
          end

          meet_comment_container.should be_false
          meet_comment.should be_true
        end
      end
    end
  end

  ##
  #
  # Short integration test using real objects instead
  # of stubs or mocks.
  #
  ##

  context "Integration Test for CommentContainer" do
    it "should meet all requirements" do
      homer = double('Homer')
      bart = double('Bart')
      nelson = double('Nelson')
      homer_comment1 = Comment.create(homer, "header", "Do!")
      homer_comment2 = Comment.create(homer, "header", "Nuts!")
      bart_comment = Comment.create(bart, "header", "Ay, caramba!")
      nelson_comment = Comment.create(nelson, "header", "Ha, Ha!")

      container = CommentContainer.new
      container.add(homer_comment1)
      homer_comment1.add(bart_comment)
      bart_comment.add(nelson_comment)
      container.add(homer_comment2)

      container.depth.should == 0
      homer_comment1.depth.should == 1
      bart_comment.depth == 2
      nelson_comment.depth == 3
      homer_comment2.depth == 1

      collected_comments = container.collect

      collected_comments[0].should equal(homer_comment1)
      collected_comments[1].should equal(bart_comment)
      collected_comments[2].should equal(nelson_comment)
      collected_comments[3].should equal(homer_comment2)

      container.travers { |comment| puts comment }
    end
  end
end
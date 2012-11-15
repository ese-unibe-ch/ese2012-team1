require "rubygems"
require "rspec"

require "require_relative"

require_relative "../../app/models/reversable_description"
require_relative "custom_matchers"

include CustomMatchers


describe "ReversableDescription" do

  def createReversableDescription
    reversable = ReversableDescription.new
  end

  context "after creation" do
    before(:each) do
      @reversable = createReversableDescription
    end

    it "should have zero descriptions" do
      @reversable.descriptions.size.should == 0
    end

    it "should have version -1" do
      @reversable.version.should == -1
    end

    it "should not be possible to show anything" do
      @reversable.show.should == ""
    end

    it "should not be possible to set a version" do
      lambda { @reversable.set_version(1) }.should raise_exception(RuntimeError)
    end

    it "should not accept negative version" do
      lambda { @reversable.set_version(-1) }.should raise_exception(RuntimeError)
    end

    it "should not accept characters in version" do
      lambda { @reversable.set_version("aa") }.should raise_exception(RuntimeError)
    end

    it "should add a description" do
      @reversable.add("I'm a comment")

      @reversable.show.should be_like "I'm a comment"
    end

    context("with one description") do
      before(:each) do
        @comment = @reversable.add("I'm a comment")
      end

      it "should have version 1" do
        @reversable.version.should == 1
      end

      it "should show added comment" do
        @reversable.add("I'm a comment")

        @reversable.show.should be_like "I'm a comment"
      end

      it "should add another description" do
        @reversable.add("I'm another comment")

        @reversable.show.should be_like "I'm another comment"
      end

      it "should be possible to set version to 1" do
        @reversable.set_version(1)
      end
    end

    context("with two descriptions") do
      before(:each) do
        @comment1 = @reversable.add("I'm a first description")
        @comment2 = @reversable.add("I'm a second description")
      end

      it "should not be possible to set version 3" do
        lambda { @reversable.set_version(3) }.should raise_exception(RuntimeError)
      end

      it "should hold two comments" do
        @reversable.descriptions.size.should == 2
      end

      it "should be possible to set version 1" do
        @reversable.set_version(1)
      end

      it "should travers over both description" do
        compared_description = ["I'm a first description", "I'm a second description"]
        compared_version = 1
        @reversable.travers do |version, description|
          version.should == compared_version
          description.should be_like compared_description[compared_version-1]
          compared_version += 1
        end
      end

      context "when set to version 1" do
        before(:each) do
          @reversable.set_version(1)
        end

        it "should show first added comment" do
          @reversable.show.should be_like "I'm a first description"
        end

        it "should be version 1" do
          @reversable.version.should == 1
        end

        it "should still have two description" do
          @reversable.descriptions.size.should == 2
        end

        it "a newly added description should have version 3" do
          @reversable.add("I'm a third description")

          @reversable.version.should == 3
          @reversable.show.should be_like "I'm a third description"
        end
      end
    end
  end
end
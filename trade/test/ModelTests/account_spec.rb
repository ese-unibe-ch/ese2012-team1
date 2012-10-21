require "rubygems"
require "rspec"

shared_examples_for "any created Account" do
    it "should have name" do
      @user.name.should be_like  "Bart"
    end

    it "should have description" do
      @user.description.should be_like "I'm Bart"
    end

    it "should have avatar path" do
      @user.avatar.should be_like "/images/users/default_avatar.png"
    end

    it "should not have an id" do
      @user.id.should be_like nil
    end

    it "should add himself to list in system" do
      @system.should_receive(:add_account)
      User.created("Bart", "password", "bart@mail.ch", "I'm Bart", "/images/users/default_avatar.png")
    end
end
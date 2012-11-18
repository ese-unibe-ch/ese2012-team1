require 'rubygems'
require "rspec"

require 'require_relative'
require_relative('../../app/controllers/navigation')

require_relative('../ModelTests/custom_matchers')

include CustomMatchers

describe "Navigation" do
  it "should create navigation" do
    navigation = Navigation.new

    navi = [["home", "/home"], ["community", "/community"], ["market", "/market"], ["logout", "/logout"]]

    navi.each do |piece|
      navigation.add_navigation(piece[0], piece[1])
    end

    navigation.select(1)
    navigation.direct_to.should == "/home"

    navigation.select(3)
    navigation.name.should == "market"

    navigation.select_by_name("community")
    navigation.name.should == "community"

    navigation.select(1)
    subnavi = [["h", "/h"], ["c", "/c"], ["m", "/m"], ["l", "/l"]]

    subnavi.each do |piece|
      navigation.add_subnavigation(piece[0], piece[1])
    end

    navigation.subnavigation.select(3)

    navigation.subnavigation.direct_to.should == "/m"
    navigation.subnavigation.name.should == "m"
    navigation.direct_to.should == "/m"

    navigation.travers do |name, direct_to|
      puts "#{name} #{direct_to}"
    end
  end
end
ENV['RACK_ENV'] = "test"

require "test/unit"
require "rubygems"
require "selenium/webdriver"
require "require_relative"

require_relative "../../app/models/user"

##
#
# Checks if Unregister works.
#
# !!! This test does not work if you already removed users by hand. Then you have to
# restart Sinatra !!!
#
##

class UnregisterTest < Test::Unit::TestCase
  def login(user, password)
    @driver.get("localhost:4567/login")

    element = @driver.find_element :name => "username"
    element.send_keys user
    element = @driver.find_element :name => "password"
    element.send_keys password

    element.submit
  end

  def setup
    @driver = Selenium::WebDriver.for :firefox
  end

  def test_logout

    begin
      login("ese", "ese")
      wait = Selenium::WebDriver::Wait.new(:timeout => 1) # seconds

      element = wait.until { @driver.find_element :name => "data" }
      element.submit

      #direct to active_items
      login("userA", "passwordA")
      logout_via("active_items")

      login("userB", "passwordB")
      logout_via("inactive_items")

      login("userC", "passwordC")
      logout_via("create_item")

      login("userD", "passwordD")
      logout_via("users")

      login("userE", "passwordE")
      logout_via("items")
    ensure
      @driver.quit
    end
  end

  def logout_via (via)
    wait = Selenium::WebDriver::Wait.new(:timeout => 1)
    element = wait.until { @driver.find_element :name => via }
    element.click
    element = @driver.find_element :name => "data"
    element.submit

    element = @driver.find_element :tag_name => "body"
    assert(! element.text.include?("Sinatra"), "Should delete user")
  end
end
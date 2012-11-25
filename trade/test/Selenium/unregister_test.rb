ENV['RACK_ENV'] = "test"

require "test/unit"
require "rubygems"
require "selenium/webdriver"

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
      login("ese@mail.ch", "ese")
      wait = Selenium::WebDriver::Wait.new(:timeout => 1) # seconds

      element = wait.until { @driver.find_element :name => "data" }
      element.submit


      logout
    ensure
      @driver.quit
    end
  end

  def logout
    wait = Selenium::WebDriver::Wait.new(:timeout => 1)
    element = wait.until { @driver.find_element :name => via }
    element.click
    element = @driver.find_element :name => "data"
    element.submit

    element = @driver.find_element :tag_name => "body"
    assert(! element.text.include?("Sinatra"), "Should delete user")
  end
end
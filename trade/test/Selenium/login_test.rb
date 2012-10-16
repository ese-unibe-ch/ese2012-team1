ENV['RACK_ENV'] = "test"

require "test/unit"
require "rubygems"
require "selenium/webdriver"

class LoginTest < Test::Unit::TestCase

  def test_login
    begin
      driver = Selenium::WebDriver.for :firefox
      driver.get("localhost:4567/login")

      element = driver.find_element :name => "username"
      element.send_keys "ese@mail.ch"
      element = driver.find_element :name => "password"
      element.send_keys "ese"

      element.submit

      element = driver.find_element :tag_name => "body"
      assert(element.text.include?("Currently logged in as"), "Should navigate to login")
    ensure
      driver.quit
    end
  end
end
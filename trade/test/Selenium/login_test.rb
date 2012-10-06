require "test/unit"
require "rubygems"
require "selenium/webdriver"

class LoginTest < Test::Unit::TestCase

  def test_login
    driver = Selenium::WebDriver.for :firefox
    driver.get("localhost:4567/login")

    element = driver.find_element :name => "username"
    element.send_keys "ese"
    element = driver.find_element :name => "password"
    element.send_keys "ese"

    element.submit

    element = driver.find_element :tag_name => "body"
    assert(element.text.include?("Currently logged in User"), "Should navigate to login")

    driver.quit
  end
end
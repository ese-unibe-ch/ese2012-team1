ENV['RACK_ENV'] = "test"

require "test/unit"
require "rubygems"
require "selenium/webdriver"

class OrganisationTest < Test::Unit::TestCase

  def login(driver)
    driver.get("localhost:4567/login")

    element = driver.find_element :name => "username"
    assert(! element.nil?, "Field to put username does not exist!")
    element.send_keys "ese@mail.ch"
    element = driver.find_element :name => "password"
    element.send_keys "ese"

    element.submit

    element = driver.find_element :tag_name => "body"
    assert(element.text.include?("Currently logged in as"), "Should navigate to login")
  end

  def test_create_organisation
    driver = Selenium::WebDriver.for :firefox

    begin
      login(driver)

      driver.get("localhost:4567/organisation/create")

      element = driver.find_element :name => "name"
      element.send_keys "found.inc"
      element = driver.find_element :name => "description"
      element.send_keys "I'm a founding incorporation"

      element.submit

      element = driver.find_element :tag_name => "body"
      assert(element.text.include?("Your Profile"))

      elements = driver.find_elements :tag_name => "option"

      assert(elements.any? { |input| input.text == "found.inc" }, "There should be one input element with text \'found.inc\'")
    ensure
      driver.quit
    end
  end
end
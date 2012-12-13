require 'require_relative'
require 'nokogiri'

require_relative "../helpers/render"

require 'singleton'

class Navigations
  include Singleton

  attr_accessor :navigations, :selected

  def initialize
    self.navigations = nil
    self.selected = nil
  end
  
  def build
    xml = Nokogiri::XML(File.open(absolute_path("navigation.xml", __FILE__)))

    navigations = Hash.new

    xml.css("context").each do |context|
      symbol_context =  context.xpath("./name").text.to_sym
      navigation = navigations.store(symbol_context, Navigation.new)

      #Select first navigation
      self.selected = navigation if (self.selected.nil?)

      context.css("navigation").each do |navigation_xml|
        navigation_name = navigation_xml.xpath("./name").text
        navigation_route =  navigation_xml.xpath("./route").text

        fail "You're xml file is corrupted: No name tag (<name><\name>) given for a navigation in context: \'#{symbol_context}\'" if navigation_name.size == 0

        navigation.add_navigation(navigation_name, navigation_route)
        navigation.select_by_name(navigation_name)

        navigation_xml.css("subnavigation").each do |subnavigation|
          subnavigation_name = subnavigation.xpath("./name").text
          subnavigation_route =  subnavigation.xpath("./route").text

          fail "You're xml file is corrupted: No name tag (<name><\name>) given for a subnavigation in navigation: \'#{navigation_name}\' for context: \'#{context}\'" if subnavigation_name.size == 0
          fail "You're xml file is corrupted: No route tag (<name><\name>) given for a subnavigation in navigation: \'#{navigation_name}\' for context: \'#{context}\'" if subnavigation_route.size == 0

          navigation.add_subnavigation(subnavigation_name, subnavigation_route)

          navigation.subnavigation.select(1)
        end

        navigation.select(1)

        self.navigations = navigations

        self
      end
    end

    self
  end

  def get
    self.navigations
  end

  def get(context)
    self.navigations[context]
  end
end
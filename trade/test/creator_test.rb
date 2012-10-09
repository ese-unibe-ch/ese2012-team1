require 'rubygems'
require 'require_relative'
require 'test/unit'
require 'helper'
require 'rack/test'
require 'ftools'

require 'test_helper'

ENV['RACK_ENV'] = 'test'

require_relative '../app/controllers/creator'
require_relative '../app/models/item'

class CreatorTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Controllers::Creator
  end

  describe 'Simple Tests' do
    class TestApp < Controllers::Creator
      configure do
        TestHelper.load
      end
    end

    it 'post /create should create a new item' do
      user = Models::User.get_user('Homer')
      assert(! user.has_item?('Gold'), "Should not own gold before post /create")

      file = Rack::Test::UploadedFile.new("../app/public/images/items/default_item.png", "image/png")

      post '/create', { :item_picture => file, :name => 'Gold', :price => 100, :description => 'Very very valuable'}, 'rack.session' => { :user => 'Homer', :auth => true  }
      assert(user.has_item?('Gold'), "Should own gold")

      # Removing File after test
      File.delete("#{user.get_item('Gold').picture.sub("images", "app/public/images")}")
    end
  end
end
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

    it 'post /home/edit/save should create a new item' do
      user = Models::User.get_user('Bart')
      item = user.get_item('Skateboard')
      item.to_inactive

      file = Rack::Test::UploadedFile.new("../app/public/images/items/default_item.png", "image/png")

      post '/home/edit/save', { :id => item.get_id, :item_picture => file, :new_description => 'Kind of used...', :new_price => 200 }, 'rack.session' => { :user => 'Homer', :auth => true  }
      assert(user.has_item?('Skateboard'), "Should own skateboard")
      assert(item.price.to_i == 200, "Should cost 200 but was #{item.price}")
      assert(item.description == 'Kind of used...', "Should be \'Kind of used...\' but was #{item.description}")

      # Removing File after test
      File.delete("#{user.get_item('Skateboard').picture.sub("images", "app/public/images")}")
    end
  end
end
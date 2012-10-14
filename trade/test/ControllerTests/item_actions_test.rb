require 'rubygems'
require 'require_relative'
require 'test/unit'
require 'helper'
require 'rack/test'
require 'ftools'

require 'test_helper'

ENV['RACK_ENV'] = 'test'

require_relative '../../app/controllers/item_actions'
require_relative '../../app/models/item'
require_relative '../../app/models/system'

class ItemActionsTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Controllers::ItemActions
  end

  describe 'Simple Tests' do

    class TestApp < Controllers::ItemActions
      configure do
        TestHelper.load
      end
    end

    it 'post /changestate/setinactive should set an item inactive' do
      items = TestHelper.get_items
      item = items[:skateboard]

      assert(item.is_active?, "Item should be active")

      post '/changestate/setinactive', {:id => item.id }, 'rack.session' => {:user => 'bart@mail.ch', :auth => true}

      assert(!item.is_active?, "Item should be inactive")
    end

    it 'post /changestate/setactive should set an item active' do
      item = Models::System.instance.fetch_user('bart@mail.ch').create_item('sling', 20)

      assert(!item.is_active?, "Item should be inactive")

      post '/changestate/setactive', {:id => item.id}, 'rack.session' => {:user => 'bart@mail.ch', :auth => true}

      assert(item.is_active?, "Item should be active")
    end

    it 'post /changestate/setactive should not set items of somebody else active' do
       item = Models::System.instance.fetch_user('bart@mail.ch').create_item('sling', 20)

       assert(!item.is_active?, "Item should be inactive")

       puts (Models::System.instance.items)

       post '/changestate/setinactive', {:id => item.id}, 'rack.session' => {:user => 'bart@mail.ch', :auth => true}

       assert(!item.is_active?, "Item should be inactive")
    end

    it 'post /create should create a new item' do
      user = Models::System.instance.fetch_user('homer@mail.ch')

      homers_items = Models::System.instance.fetch_items_of(user.email)
      assert(!homers_items.include?('Gold'), "Should not own gold before post /create")

      file = Rack::Test::UploadedFile.new("../../app/public/images/items/default_item.png", "image/png")

      post '/create', { :item_picture => file, :name => 'Gold', :price => 100, :description => 'Very very valuable'}, 'rack.session' => { :user => user.email, :auth => true  }

      homers_items = Models::System.instance.fetch_items_of(user.email)
      item = homers_items.detect{|item| item.name == 'Gold'}
      assert(item.name == 'Gold', "Should own gold but instead did own: #{homers_items}")

      # Removing File after test
      File.delete("#{item.picture.sub("images", "../app/public/images")}")
    end

    it 'post /home/edit/save should save changes' do
      items = TestHelper.get_items
      users = TestHelper.get_users

      item = items[:skateboard]
      item.to_inactive

      file = Rack::Test::UploadedFile.new("../../app/public/images/items/default_item.png", "image/png")

      post '/home/edit/save', { :id => item.id, :item_picture => file, :new_description => 'Kind of used...', :new_price => 200 }, 'rack.session' => { :user => 'bart@mail.ch', :auth => true  }
      assert(users[:bart].has_item?(item.id), "Should own skateboard")
      assert(item.price.to_i == 200, "Should cost 200 but was #{item.price}")
      assert(item.description == 'Kind of used...', "Should be \'Kind of used...\' but was #{item.description}")
      assert(item.picture == "../images/items/#{item.id}.png", "Path to file should be ../images/items/#{item.id}.png but was #{item.picture}")

      # Removing File after test
      File.delete("#{item.picture.sub("images", "../app/public/images")}")
    end
  end
end
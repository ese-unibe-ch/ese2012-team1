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

    it 'post /item/changestate/setinactive should set an item inactive' do
      items = TestHelper.get_items
      users = TestHelper.get_users
      item = items[:skateboard]

      assert(item.is_active?, "Item should be active")

      post '/item/changestate/setinactive', { :id => item.id }, 'rack.session' => {:user => users[:bart].id, :auth => true, :account => users[:bart].id}

      assert(!item.is_active?, "Item should be inactive")
    end

    it 'post /item/changestate/setactive should set an item active' do
      user = Models::System.instance.fetch_user_by_email('bart@mail.ch')
      item = user.create_item('sling', 20)

      assert(!item.is_active?, "Item should be inactive")

      post '/item/changestate/setactive', {:id => item.id}, 'rack.session' => {:user => user.id, :auth => true, :account => user.id}

      assert(item.is_active?, "Item should be active")
    end

    it 'post /item/changestate/setactive should not set items of somebody else active' do
       item = Models::System.instance.fetch_user_by_email('bart@mail.ch').create_item('sling', 20)

       assert(!item.is_active?, "Item should be inactive")

       puts (Models::System.instance.items)

       post '/item/changestate/setinactive', {:id => item.id}, 'rack.session' => {:user => 'bart@mail.ch', :auth => true}

       assert(!item.is_active?, "Item should be inactive")
    end

    it 'post /item/create should create a new item' do
      user = Models::System.instance.fetch_user_by_email('homer@mail.ch')

      homers_items = Models::System.instance.fetch_items_of(user.id)
      assert(!homers_items.include?('Gold'), "Should not own gold before post /create")

      file = Rack::Test::UploadedFile.new("../../app/public/images/items/default_item.png", "image/png")

      post '/item/create', { :item_picture => file, :name => 'Gold', :price => 100, :description => 'Very very valuable'}, 'rack.session' => { :user => user.id, :auth => true, :account => user.id }

      homers_items = Models::System.instance.fetch_items_of(user.id)
      item = homers_items.detect{|item| item.name == 'Gold'}
      assert(item.name == 'Gold', "Should own gold but instead did own: #{homers_items}")

      # Removing File after test
      File.delete("#{item.picture.sub("images", "../app/public/images")}")
    end

    it 'post /item/edit/save should save changes' do
      items = TestHelper.get_items
      users = TestHelper.get_users

      item = items[:skateboard]
      item.to_inactive

      file = Rack::Test::UploadedFile.new("../../app/public/images/items/default_item.png", "image/png")

      post '/item/edit/save', { :id => item.id, :item_picture => file, :new_description => 'Kind of used...', :new_price => 200 }, 'rack.session' => { :user => 'bart@mail.ch', :auth => true  }
      assert(users[:bart].has_item?(item.id), "Should own skateboard")
      assert(item.price.to_i == 200, "Should cost 200 but was #{item.price}")
      assert(item.description == 'Kind of used...', "Should be \'Kind of used...\' but was #{item.description}")
      assert(item.picture == "../images/items/#{item.id}.png", "Path to file should be ../images/items/#{item.id}.png but was #{item.picture}")

      # Removing File after test
      File.delete("#{item.picture.sub("images", "../app/public/images")}")
    end
  end
end
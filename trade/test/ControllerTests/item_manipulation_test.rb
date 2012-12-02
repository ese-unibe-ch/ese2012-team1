require 'controller_require'

class ItemManipulationTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Controllers::ItemManipulation
  end

  describe 'Simple Tests' do

    class TestApp < Controllers::ItemManipulation
      configure do
        TestHelper.load
      end
    end

    setup do
      @users = TestHelper.get_users
      @items = TestHelper.get_items
    end

    it 'post /item/changestate/setinactive should set an item inactive' do
      item = @items[:skateboard]

      assert(item.is_active?, "Item should be active")

      post '/item/changestate/setinactive', { :id => item.id }, 'rack.session' => {:user => @users[:bart].id, :auth => true, :account => @users[:bart].id}

      assert(!item.is_active?, "Item should be inactive")
    end

    it 'post /item/changestate/setactive should set an item active' do
      user = @users[:bart]
      item = user.create_item('sling', 20)

      assert(!item.is_active?, "Item should be inactive")

      post '/item/changestate/setactive', {:id => item.id}, 'rack.session' => {:user => user.id, :auth => true, :account => user.id}

      assert(item.is_active?, "Item should be active")
    end

    it 'post /item/changestate/setactive should not set items of somebody else active' do
      item = Models::System.instance.fetch_user_by_email('bart@mail.ch').create_item('sling', 20)

      assert(!item.is_active?, "Item should be inactive")

      post '/item/changestate/setinactive', {:id => item.id}, 'rack.session' => {:user => @users[:bart].id, :auth => true}

      assert(!item.is_active?, "Item should be inactive")
    end

    it 'post /item/edit/save should save changes' do
      item = @items[:skateboard]
      item.to_inactive

      file = Rack::Test::UploadedFile.new("../../app/public/images/items/default_item.png", "image/png")

      post '/item/edit/save', { :id => item.id, :item_picture => file, :new_description => 'Kind of used...', :new_price => 200 }, 'rack.session' => { :account => @users[:bart].id, :user => @users[:bart].id, :auth => true  }

      assert(@users[:bart].has_item?(item.id), "Should own skateboard")
      assert(item.price.to_i == 200, "Should cost 200 but was #{item.price}")
      assert(item.description == 'Kind of used...', "Should be \'Kind of used...\' but was #{item.description}")
      assert(item.picture == "/images/items/#{item.id}.png", "Path to file should be /images/items/#{item.id}.png but was #{item.picture}")

      # Removing File after test
      File.delete("#{item.picture.sub("/images", "../../app/public/images")}")
    end

    it 'post /item/edit/save with correct data should redirect to /items/my/all' do
      item = @items[:skateboard]
      item.to_inactive

      file = Rack::Test::UploadedFile.new("../../app/public/images/items/default_item.png", "image/png")

      post '/item/edit/save', { :id => item.id, :item_picture => file, :new_description => 'Kind of used...', :new_price => 200 }, 'rack.session' => { :account => @users[:bart].id, :user => @users[:bart].id, :auth => true  }

      assert(last_response.location.include?('/items/my/all'), "Should redirect to /items/my/all but was #{last_response.location}")

      # Removing File after test
      File.delete("#{item.picture.sub("/images", "../../app/public/images")}")
    end
  end
end
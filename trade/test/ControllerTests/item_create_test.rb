require 'controller_require'

class ItemCreateTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Controllers::ItemCreate
  end

  describe 'Simple Tests' do

    class TestApp < Controllers::ItemCreate
      configure do
        TestHelper.load
      end
    end

    it 'post /item/create should create a new item' do
      user = DAOAccount.instance.fetch_user_by_email('homer@mail.ch')

      homers_items = DAOItem.instance.fetch_items_of(user.id)
      assert(!homers_items.include?('Gold'), "Should not own gold before post /create")

      file = Rack::Test::UploadedFile.new("../../app/public/images/items/default_item.png", "image/png")

      post '/item/create', { :item_picture => file, :name => 'Gold', :price => 100, :description => 'Very very valuable'}, 'rack.session' => { :user => user.id, :auth => true, :account => user.id }

      homers_items = DAOItem.instance.fetch_items_of(user.id)
      item = homers_items.detect{|item| item.name == 'Gold'}

      assert(item.name == 'Gold', "Should own gold but instead did own: #{homers_items}")
      assert(item.description == 'Very very valuable', "Should have description \'Very very valuable' but was #{item.description}")
      assert(item.price == 100, "Should cost 100 credits but was #{item.price}")

      # Removing File after test
      File.delete("#{item.picture.sub("/images", "../../app/public/images")}")
    end
  end
end
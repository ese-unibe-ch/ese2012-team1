require 'rubygems'
require 'require_relative'
require 'test/unit'
require 'helper'
require 'rack/test'

ENV['RACK_ENV'] = 'test'

require_relative '../app/app'
require_relative '../app/models/user'

class MainTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    App
  end

  describe 'Simple Tests' do
    class TestApp < App
      configure do
        bart = Models::User.created('Bart' , 'bart')
        bart.create_item('Skateboard', 100)
        bart.list_items_inactive.detect {|item| item.name == 'Skateboard' }.to_active

        homer = Models::User.created('Homer', 'homer')
        homer.create_item('Beer', 200)
        homer.list_items_inactive.detect {|item| item.name == 'Beer' }.to_active
      end
    end

    it 'get /home as Homer should show home site' do
      get '/home', {}, 'rack.session' => { :user => 'Homer', :auth => true  }
      assert last_response.ok?
      assert last_response.body.include?('Trading System'), "Should show title but was\n#{last_response.body}"
    end

    it 'get / logged in should redirect to home' do
      get '/', {}, 'rack.session' => { :user => 'Homer', :auth => true  }
      assert last_response.redirect?
      assert last_response.location.include?('/home')
    end
  end
end
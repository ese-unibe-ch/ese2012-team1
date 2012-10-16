require 'rubygems'
require 'require_relative'
require 'test/unit'
require 'helper'
require 'rack/test'

require 'test_helper'

ENV['RACK_ENV'] = 'test'

require_relative '../../app/app'
require_relative '../../app/models/user'

class MainTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    App
  end

  describe 'Simple Tests' do
    class TestApp < App
      configure do
        TestHelper.load
      end
    end

    it 'get /home as Homer should his show home site' do
      users = TestHelper.get_users
      puts(users)
      puts((users[:homer]).id)
      get '/home', {}, 'rack.session' => { :user => users[:homer].id, :auth => true, :account => users[:homer].id  }
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
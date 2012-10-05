require 'rubygems'
require 'require_relative'
require 'test/unit'
require 'helper'
require 'rack/test'

require 'test_helper'

ENV['RACK_ENV'] = 'test'

require_relative '../app/controllers/registration'
require_relative '../app/models/user'

class RegistrationTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Controllers::Registration
  end

  describe 'Simple Tests' do
    class TestApp < Controllers::Registration
      configure do
        TestHelper.load
      end
    end

    it 'post /register should redirect to /register if password is too short' do
      post "/register", {:password => 'aB1De'}, 'rack.session' => session =  { :user => nil, :auth => false  }
      assert last_response.redirect?, "Should redirect but was #{last_response.body}"
      assert last_response.location.include?('/register')
    end

    it 'post /register should redirect to /register if password holds special characters' do
      post "/register", {:password => '$onn3nBad', :user => 'Larry'}, 'rack.session' => session =  { :user => nil, :auth => false  }
      assert last_response.redirect?, "Should redirect but was #{last_response.body}"
      assert last_response.location.include?('/register')
    end

    it 'post /register should redirect to /register if password is too weak' do
      fail("Not yet implemented")

      post "/register", {:password => 'aaaagsfa'}, 'rack.session' => session =  { :user => nil, :auth => false  }
      assert last_response.redirect?, "Should redirect but was #{last_response.body}"
      assert last_response.location.include?('/register')

      post "/register", {:password => '13232341'}, 'rack.session' => session =  { :user => nil, :auth => false  }
      assert last_response.redirect?, "Should redirect but was #{last_response.body}"
      assert last_response.location.include?('/register')

      post "/register", {:password => 'DGGEGHRSEGA'}, 'rack.session' => session =  { :user => nil, :auth => false  }
      assert last_response.redirect?, "Should redirect but was #{last_response.body}"
      assert last_response.location.include?('/register')
    end

    it 'post /register should redirect to /login if password is okey' do
      post "/register", {:password => 'B4rney', :name => 'Barney'}, 'rack.session' => session =  { :user => nil, :auth => false  }
      assert last_response.redirect?, "Should redirect but was #{last_response.body}"
      assert last_response.location.include?('/login')
    end

    it 'post /register should add user to system' do
      post "/register", {:password => 'aB12De', :name => 'Matz'}, 'rack.session' => session =  { :user => nil, :auth => false  }
      user = Models::User.get_user('Matz')
      assert(user != nil, "User should exist within system")
    end

    it 'get /register should add script and load initialize' do
      get '/register'
      assert last_response.ok?
      assert last_response.body.include?('passwordchecker.js'), "Should include script for password checking but was\n#{last_response.body}"
      assert last_response.body.include?('onload=\'initialize()\''), "Should load initialize() in body but was\n#{last_response.body}"
    end

    it 'get /register should show registration.html' do
      get '/register'
      assert last_response.ok?
      assert last_response.body.include?('Name:'), "Should ask for name but was\n#{last_response.body}"
      assert last_response.body.include?('Password:'), "Should ask for password but was\n#{last_response.body}"
      assert last_response.body.include?('Description:'), "Should ask for description but was\n#{last_response.body}"
      assert last_response.body.include?('Avatar:'), "Should ask for avatar but was\n#{last_response.body}"
      assert last_response.body.include?('Email:'), "Should ask for email but was\n#{last_response.body}"
      assert last_response.body.include?('Password:'), "Should ask for password but was\n#{last_response.body}"
    end

    it 'post /unregister should remove Homer from list of users' do
      assert User.get_user('Bart') != nil, "Homer should exist"
      post '/unregister', {}, 'rack.session' => session =  { :user => 'Bart', :auth => true  }
      assert User.get_user('Bart') == nil, "Homer should not exist anymore"
    end

    it 'post /unregister should redirect to /unauthenticate' do
      post '/unregister', {}, 'rack.session' => session =  { :user => 'Homer', :auth => true  }
      assert last_response.redirect?
      assert last_response.location.include?('/unauthenticate'), "Should redirect to /unauthenticate"
    end
  end
end
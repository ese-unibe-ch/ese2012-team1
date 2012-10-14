require 'rubygems'
require 'require_relative'
require 'test/unit'
require 'helper'
require 'rack/test'

require 'test_helper'

ENV['RACK_ENV'] = 'test'

require_relative '../../app/controllers/registration'
require_relative '../../app/models/user'

class RegistrationTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Controllers::Registration
  end

  describe 'Registration' do
    class TestApp < Controllers::Registration
      configure do
        TestHelper.load
      end
    end

    it 'post /register should redirect to /register if password is too short' do
      post "/register", {:password => 'aB1De', :re_password => 'aB1De'}, 'rack.session' => session =  { :user => nil, :auth => false  }
      assert last_response.redirect?, "Should redirect but was #{last_response.body}"
      assert last_response.location.include?('/register')
    end

    it 'post /register should redirect to /register if password holds special characters' do
      post "/register", {:password => '$onn3nBad', :re_password => '$onn3nBad', :name => 'Larry'}, 'rack.session' => session =  { :user => nil, :auth => false  }
      assert last_response.redirect?, "Should redirect but was #{last_response.body}"
      assert last_response.location.include?('/register')
    end

    it 'post /register should redirect to /register if password retype is wrong' do
      post "/register", {:password => 'Aonn3nBad', :re_password => 'fonn3nBad', :name => 'Larry'}, 'rack.session' => session =  { :user => nil, :auth => false  }
      assert last_response.redirect?, "Should redirect but was #{last_response.body}"
      assert last_response.location.include?('/register')
    end

    it 'post /register should redirect to /register if password is too weak' do
      post "/register", {:password => 'aaaagsfa', :re_password => 'aaaagsfa'}, 'rack.session' => session =  { :user => nil, :auth => false  }
      assert last_response.redirect?, "Should redirect but was #{last_response.body}"
      assert last_response.location.include?('/register')

      post "/register", {:password => '13232341', :re_password => '13232341'}, 'rack.session' => session =  { :user => nil, :auth => false  }
      assert last_response.redirect?, "Should redirect but was #{last_response.body}"
      assert last_response.location.include?('/register')

      post "/register", {:password => 'DGGEGHRSEGA', :re_password => 'DGGEGHRSEGA'}, 'rack.session' => session =  { :user => nil, :auth => false  }
      assert last_response.redirect?, "Should redirect but was #{last_response.body}"
      assert last_response.location.include?('/register')
    end

    it 'post /register should redirect to /login if password is okey' do
      post "/register", {:password => 'aB12De', :re_password => 'aB12De', :name => 'Larry', :description => "Perl is a Pearl!",
                         :email => 'larry@mail.ch'},
           'rack.session' => session =  { :user => nil, :auth => false  }
      assert last_response.redirect?, "Should redirect but was #{last_response.body}"
      assert last_response.location =~ /\/$/, "Should redirect to /login but was #{last_response.location}"
    end

    it 'post /register should add user to system' do
      post "/register", {:password => 'aB12De', :re_password => 'aB12De', :name => 'Matz', :interests => "Ruby rocks!",
                         :email => 'matz@mail.ch'},
           'rack.session' => session =  { :user => nil, :auth => false  }
      user = Models::System.instance.users.fetch('matz@mail.ch')
      assert(user != nil, "User should exist within system")
      assert(user.name == 'Matz', "User should be called Matz but was #{user.name}");
      assert(user.email == 'matz@mail.ch', "User should have email matz@mail.ch but was #{user.email}")
      assert(user.description == 'Ruby rocks!', "Description should be 'Ruby rocks!' but was '#{user.description}'")
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
      assert Models::System.instance.users.member?('bart@mail.ch'), "Bart should exist"
      post '/unregister', {}, 'rack.session' => session =  { :user => 'bart@mail.ch', :auth => true  }
      assert !Models::System.instance.users.member?('bart@mail.ch'), "Bart should not exist anymore"
    end

    it 'post /unregister should redirect to /unauthenticate' do
      post '/unregister', {}, 'rack.session' => session =  { :user => 'homer@mail.ch', :auth => true  }
      assert last_response.redirect?
      assert last_response.location.include?('/unauthenticate'), "Should redirect to /unauthenticate"
    end
  end
end
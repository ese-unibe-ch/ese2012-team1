require 'rubygems'
require 'require_relative'
require 'test/unit'
require 'helper'
require 'rack/test'

require 'test_helper'

ENV['RACK_ENV'] = 'test'

require_relative '../../app/controllers/authentication'
require_relative '../../app/models/user'

class AuthenticationTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Controllers::Authentication
  end

  describe 'Simple Tests' do
    class TestApp < Controllers::Authentication
      configure do
        TestHelper.load
      end
    end

    it 'get /login should show login.html' do
      get '/login', {}, 'rack.session' => { :user => nil, :auth => false  }
      assert last_response.ok?
      assert last_response.body.include?('E-Mail:'), "Should ask for name but was\n#{last_response.body}"
      assert last_response.body.include?('Password:'), "Should ask for password but was\n#{last_response.body}"
    end

    it 'get / should show index.html' do
      get '/', {}, 'rack.session' => { :user => nil, :auth => false  }
      assert last_response.ok?
      assert last_response.body.include?('Welcome to the Trading System!'), "Should give a warm welcome but was\n#{last_response.body}"
      assert last_response.body.include?('href=\'/login\''), "Should have link to login"
    end

    it 'post /authenticate should redirect to /home' do
      post "/authenticate", :username => "homer@mail.ch", :password => 'homer', 'rack.session' => { :user => nil, :auth => false  }
      assert last_response.redirect?, "Should redirect but was #{last_response.body}"
      assert last_response.location.include?('/home')
    end

    it 'post /authenticate with wrong password should show login.hmtl and error message' do
      post "/authenticate", :username => "homer@mail.ch", :password => 'omer', 'rack.session' => { :user => nil, :auth => false  }
      assert last_response.ok?
      assert last_response.body.include?('Login')
      assert last_response.body.include?('No such user')
    end

    it 'post /unauthenticate should reset session[:name] and session[:auth] and redirect to /' do
      session =  { :user => 'Homer', :auth => true  }
      post "/unauthenticate", {}, 'rack.session' => session
      assert session[:user] == nil, "Should reset \':user\' to nil but was #{session[:user]}"
      assert !session[:auth], "Should set \'auth\' to false but was #{session[:auth]}"
      assert last_response.redirect?, "Should redirect but was #{last_response.body}"
      assert last_response.location =~ /\/$/
    end
  end
end
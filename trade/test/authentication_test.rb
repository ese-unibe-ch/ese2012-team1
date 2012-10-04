require 'rubygems'
require 'require_relative'
require 'test/unit'
require 'helper'
require 'rack/test'

ENV['RACK_ENV'] = 'test'

require_relative '../app/controllers/authentication'
require_relative '../app/models/user'

class AuthenticationTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Controllers::Authentication
  end

  describe 'Simple Tests' do
    class TestApp < Controllers::Authentication
      configure do
        bart = Models::User.created('Bart' , 'bart')
        bart.create_item('Skateboard', 100)
        bart.list_items_inactive.detect {|item| item.name == 'Skateboard' }.to_active

        homer = Models::User.created('Homer', 'homer')
        homer.create_item('Beer', 200)
        homer.list_items_inactive.detect {|item| item.name == 'Beer' }.to_active

        bart.save
        homer.save
      end
    end

    it 'get /login should show login.html' do
      get '/login', {}, 'rack.session' => { :user => nil, :auth => false  }
      assert last_response.ok?
      assert last_response.body.include?('Name:'), "Should ask for name but was\n#{last_response.body}"
      assert last_response.body.include?('Password:'), "Should ask for password but was\n#{last_response.body}"
    end

    it 'get / should show index.html' do
      get '/', {}, 'rack.session' => { :user => nil, :auth => false  }
      assert last_response.ok?
      assert last_response.body.include?('Welcome to the Trading System!'), "Should give a warm welcome but was\n#{last_response.body}"
      assert last_response.body.include?('href=\'/login\''), "Should have link to login"
    end

    it 'post /authenticate should redirect to /home' do
      post "/authenticate", :username => "Homer", :password => 'homer', 'rack.session' => { :user => nil, :auth => false  }
      assert last_response.redirect?, "Should redirect but was #{last_response.body}"
      assert last_response.location.include?('/home')
    end

    it 'post /unauthenticate should reset session[:name] and session[:auth] and redirect to /' do
      session =  { :user => 'Homer', :auth => true  }
      post "/unauthenticate", {}, 'rack.session' => session
      assert session[:user] == nil, "Should reset \':user\' to nil but was #{session[:user]}"
      assert !session[:auth], "Should set \'auth\' to false but was #{session[:auth]}"
      assert last_response.redirect?, "Should redirect but was #{last_response.body}"
      assert last_response.location.include?('/')
    end

    it 'get /register should show registration.html' do
      get '/register'
      assert last_response.body.include?('Name:'), "Should ask for name but was\n#{last_response.body}"
      assert last_response.body.include?('Password:'), "Should ask for password but was\n#{last_response.body}"
      assert last_response.body.include?('Description:'), "Should ask for description but was\n#{last_response.body}"
      assert last_response.body.include?('Avatar:'), "Should ask for avatar but was\n#{last_response.body}"
      assert last_response.body.include?('Email:'), "Should ask for email but was\n#{last_response.body}"
      assert last_response.body.include?('Password:'), "Should ask for password but was\n#{last_response.body}"
    end
  end
end